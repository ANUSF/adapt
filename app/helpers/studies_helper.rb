module StudiesHelper
  def date(date_string)
    begin PartialDate.new(date_string) rescue nil end.to_s
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
