module Adapt::ModelSupport
  def parse_and_validate_date(attribute, value, min_year = 1000, max_year = 2999)
    result = false
    begin
      begin
        date = PartialDate.new(value)
      rescue
        date = PartialDate.new(Date.parse(value))
      end
    rescue => ex
      errors.add attribute, "#{ex.message.capitalize}: '#{value}'."
    else
      if not (min_year..max_year).include? date.year
        errors.add attribute, "Invalid year: #{date.year}"
      else
        result = date
      end
    end
    result
  end
end
