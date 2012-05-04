require "valium/version"
require 'active_record'

module Valium
  if ActiveRecord::VERSION::MAJOR == 3

    if ActiveRecord::VERSION::MINOR == 0 # We need to use the old deserialize code

      CollectionProxy = ActiveRecord::Associations::AssociationProxy

      CollectionProxy.class_eval do
        delegate :scoping, :klass, :to => :scoped
      end

      def valium_deserialize(value, klass)
        if value.is_a?(String) && value =~ /^---/
          result = YAML::load(value) rescue value
          if result.nil? || result.is_a?(klass)
            result
          else
            raise SerializationTypeMismatch,
              "Expected a #{klass}, but was a #{result.class}"
          end
        else
          value
        end
      end

    else # we're on 3.1+, yay for coder.load!

      CollectionProxy = ActiveRecord::Associations::CollectionProxy

      def valium_deserialize(value, coder)
        coder.load(value)
      end

    end # Minor version check

    def value_of(*attr_names)
      options = attr_names.last.kind_of?(Hash) ? attr_names.pop : {}

      attr_names.map! do |attr_name|
        attr_name = attr_name.to_s
        attr_name == 'id' ? primary_key : attr_name
      end

      if attr_names.size > 1
        valium_select_multiple(attr_names, options)
      else
        valium_select_one(attr_names.first, options)
      end
    end
    alias :values_of :value_of

    def hash_value_of(*args)
      args << { :as_hash => true }
      value_of(*args)
    end
    alias :hash_values_of :hash_value_of

    def valium_select_multiple(attr_names, options = {} )
      columns = attr_names.map {|n| columns_hash[n]}
      coders  = attr_names.map {|n| serialized_attributes[n]}

      connection.select_rows(
        except(:select).select(attr_names.map {|n| arel_table[n]}).to_sql
      ).map! do |values|
        values.each_with_index do |value, index|
          values[index] = valium_cast(value, columns[index], coders[index])
        end
        values = Valium::Util.hashify(attr_names, values) if options[:as_hash]
        values
      end
    end

    def valium_select_one(attr_name, options = {})
      column = columns_hash[attr_name]
      coder  = serialized_attributes[attr_name]

      connection.select_rows(
        except(:select).select(arel_table[attr_name]).to_sql
      ).map! do |values|
        result = valium_cast(values[0], column, coder)
        result = { attr_name => result } if options[:as_hash]
        result
      end
    end

    def valium_cast(value, column, coder_or_klass)
      if value.nil? || !column
        value
      elsif coder_or_klass
        valium_deserialize(value, coder_or_klass)
      else
        column.type_cast(value)
      end
    end

    module ValueOf
      def value_of(*args)
        options = args.last.kind_of?(Hash) ? args.pop : {}
        args.map! do |attr_name|
          attr_name = attr_name.to_s
          attr_name == 'id' ? klass.primary_key : attr_name
        end

        if loaded? && (empty? || args.all? {|a| first.attributes.has_key? a})
          if args.size > 1
            to_a.map do |record|
              result = args.map { |a| record[a] }
              result = Valium::Util.hashify(args, result) if options[:as_hash]
              result
            end
          else
            to_a.map do |record|
              options[:as_hash] ? { args[0] => record[args[0]]} : record[args[0]]
            end
          end
        else
          args << options
          scoping { klass.value_of(*args) }
        end
      end


      def hash_value_of(*args)
        args << { :as_hash => true }
        value_of(*args)
      end

    end

    alias :values_of :value_of
    alias :hash_values_of :hash_value_of

  end # Major version check

  module Util

    def self.hashify(keys, values)
      hash = {}
      keys.size.times { |i| hash[ keys[i] ] = values[i] }
      hash
    end

  end

end

ActiveRecord::Base.extend Valium
ActiveRecord::Relation.send :include, Valium::ValueOf
Valium::CollectionProxy.send :include, Valium::ValueOf
