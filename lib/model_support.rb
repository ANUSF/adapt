module ModelSupport
  def parse_and_validate_date(attribute, value,
                              min_year = 1000, max_year = 2999)
    result = false
    begin
      date = PartialDate.new(value)
    rescue => ex
      errors.add attribute, ex.message
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
