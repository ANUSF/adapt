module ModelSupport
  def parse_and_validate_date(attribute, value,
                              min_year = 1000, max_year = 2999)
    result = false
    if value.strip =~ /\A\d{4}\z/
      date = Date.new(value.to_i)
    else
      date = begin Date.parse(value) rescue nil end
    end
    if date
      if value =~ /\b\d\d?\/\d\d?\/\d{2,4}\b/
        errors.add attribute, "Ambiguous date format."
      elsif not (min_year..max_year).include? date.year
        errors.add attribute, "Invalid year: #{date.year}"
      else
        result = date
      end
    else
      errors.add attribute, "Unknown date format."
    end
    result
  end
end
