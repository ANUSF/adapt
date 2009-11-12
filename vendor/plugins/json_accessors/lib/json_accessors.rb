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
      def json_field(name)
        define_method("#{name}=") do |value|
          if try(:is_repeatable?, name)
            # -- filters empty entries from a repeatable field
            value = value.values if value.is_a? Hash
            value = if try(:subfields, name).empty?
              value.reject &:blank?
            else
              value.reject { |x| x.values.all? &:blank? }
            end
          end
          write_json(read_json.merge({ name.to_s => value }))
        end

        define_method(name) do
          read_json()[name.to_s]
        end
      end

      def json_fields(*names)
        names.each { |name| json_field(name) }
      end

      private
      def try(method_name, *args)
        self.send method_name, *args if self.respond_to? method_name
      end
    end

    module InstanceMethods
      def read_json
        text = read_attribute(self.json_column_name) || "{}"
        ActiveSupport::JSON.decode text
      end

      def write_json(fields)
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
