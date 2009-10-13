module Accessors
  def json_accessors(name)
    define_method("#{name}=") do |value|
      fields = ActiveSupport::JSON.decode(read_attribute :additional_metadata)
      fields[name.to_s] = value
      write_attribute :additional_metadata, fields.to_json
    end

    define_method(name) do
      fields = ActiveSupport::JSON.decode(read_attribute :additional_metadata)
      fields[name.to_s]
    end
  end
end
