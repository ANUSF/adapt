require 'active_record'

module AnuSF
  module JsonAccessors
    def self.included(mod)
      mod.extend(ActsMethods)
    end

    module ActsMethods
      def accesses_via_json(column_name)
        class_inheritable_accessor :json_column_name
        self.json_column_name = column_name.to_sym
        
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      def json_accessors(name)
        define_method("#{name}=") do |value|
          fields = read_json_fields
          fields[name.to_s] = value
          write_json_fields(fields)
        end

        define_method(name) do
          read_json_fields()[name.to_s]
        end
      end
    end

    module InstanceMethods
      def read_json_fields
        ActiveSupport::JSON.decode(read_attribute(self.json_column_name) ||
                                   "{}")
      end

      def write_json_fields(fields)
        write_attribute self.json_column_name, fields.to_json
      end
    end
  end
end

# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it

ActiveRecord::Base.class_eval do
  include AnuSF::JsonAccessors
end
