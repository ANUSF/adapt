module Accessors
  def multi_select(name)
    define_method("#{name}=") do |items|
      write_attribute name, items.to_json
    end

    define_method(name) do
      content = read_attribute name
      if content.blank?
        []
      else
        ActiveSupport::JSON.decode(read_attribute name)
      end
    end
  end
end
