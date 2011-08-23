require "valium/version"
require 'active_record'

module Valium
  if ActiveRecord::VERSION::MAJOR == 3

    if ActiveRecord::VERSION::MINOR == 0 # We need to use the old deserialize code

      def [](attr_name)
        attr_name = attr_name.to_s
        column = columns_hash[attr_name]
        if column.text? && serialized_attributes.include?(attr_name)
          serialized_klass = serialized_attributes[attr_name]
        end

        connection.select_values(
          select(arel_table[attr_name]).to_sql
        ).map! do |value|
          if value.nil? || !column
            value
          elsif serialized_klass
            deserialize_value(value, serialized_klass)
          else
            column.type_cast(value)
          end
        end
      end

      def deserialize_value(value, klass)
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

      def [](attr_name)
        attr_name = attr_name.to_s
        column = columns_hash[attr_name]
        if column.text? && serialized_attributes.include?(attr_name)
          coder = serialized_attributes[attr_name]
        end

        connection.select_values(
          select(arel_table[attr_name]).to_sql
        ).map! do |value|
          if value.nil? || !column
            value
          elsif coder
            coder.load(value)
          else
            column.type_cast(value)
          end
        end
      end

    end # Minor version check

    module Relation
      def [](*args)
        if args.size == 1 && [String, Symbol].any? {|c| c === args.first}
          scoping { @klass[args.first] }
        else
          to_a[*args]
        end
      end
    end

  end # Major version check
end

ActiveRecord::Base.extend Valium
ActiveRecord::Relation.send :include, Valium::Relation