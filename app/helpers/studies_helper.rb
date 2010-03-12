module StudiesHelper
  def date(date_string)
    if date_string.strip =~ /\A\d{4}\z/
      Date.new(date_string.to_i)
    else
      begin Date.parse(date_string) rescue nil end
    end.to_s
  end

  def each(list, &block)
    (list.blank? ? [] : list).each &block
  end

  def access_text(study)
    if study.licence.nil? or study.licence.access_mode.blank?
      nil
    else
      "#{study.licence.access_mode} (#{study.licence.access_phrase})"
    end
  end
end
