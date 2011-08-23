require "valium/version"
require 'active_record'

module Valium
  if ActiveRecord::VERSION::MAJOR == 3

    if ActiveRecord::VERSION::MINOR == 0 # We need to use the old deserialize code

      def [](*attr_names)
        attr_names = attr_names.map(&:to_s)

        results = connection.select_rows(
          select(attr_names.map {|n| arel_table[n]}).to_sql
        ).map! do |values|
          values.each_with_index do |value, index|
            if value.nil? || !columns_hash[attr_names[index]]
              # Don't modify
            elsif serialized_attributes[attr_names[index]]
              values[index] = deserialize_value(value, serialized_attributes[attr_names[index]])
            else
              values[index] = columns_hash[attr_names[index]].type_cast(value)
            end
          end
          values
        end

        attr_names.size > 1 ? results : results.flatten!
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

      def [](*attr_names)
        attr_names = attr_names.map(&:to_s)

        results = connection.select_rows(
          select(attr_names.map {|n| arel_table[n]}).to_sql
        ).map! do |values|
          values.each_with_index do |value, index|
            if value.nil? || !columns_hash[attr_names[index]]
              # Don't modify
            elsif serialized_attributes[attr_names[index]]
              values[index] = serialized_attributes[attr_names[index]].load(value)
            else
              values[index] = columns_hash[attr_names[index]].type_cast(value)
            end
          end
          values
        end

        attr_names.size > 1 ? results : results.flatten!
      end

    end # Minor version check

    module Relation
      def [](*args)
        if args.size > 0 && args.all? {|a| String === a || Symbol === a}
          scoping { @klass[*args] }
        else
          to_a[*args]
        end
      end
    end

  end # Major version check
end

ActiveRecord::Base.extend Valium
ActiveRecord::Relation.send :include, Valium::Relation