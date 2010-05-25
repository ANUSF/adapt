module ANUSF
  module JsonAccessors
    module ClassMethods
      def json_field(name)
        define_method("#{name}=") do |value|
          if try(:is_repeatable?, name)
            # -- filters empty entries from a repeatable field
            value = value.values if value.is_a? Hash
            value = if (try(:subfields, name) || []).empty?
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

class ActiveRecord::Base
  def self.accesses_via_json(column_name)
    class_inheritable_accessor :json_column_name
    self.json_column_name = column_name.to_sym
        
    extend ANUSF::JsonAccessors::ClassMethods
    include ANUSF::JsonAccessors::InstanceMethods
  end
end
