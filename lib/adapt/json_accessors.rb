module Adapt::JsonAccessors
  def self.included(base)
    base.class_eval do
      class_attribute :json_column_name
      self.json_column_name = :json_data
      
      extend Adapt::JsonAccessors::ClassMethods
      include Adapt::JsonAccessors::InstanceMethods
    end
  end

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
  end

  module InstanceMethods
    def read_json
      text = read_attribute(self.json_column_name) || "{}"
      ActiveSupport::JSON.decode text
    end

    def write_json(fields)
      write_attribute self.json_column_name, fields.to_json
    end

    private
    # Rails' Object#try seems broken
    def try(method_name, *args)
      self.send method_name, *args if self.respond_to? method_name
    end
  end
end
