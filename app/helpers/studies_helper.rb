module StudiesHelper
  def date(date_string)
    begin Date.parse(date_string.to_s.strip) rescue nil end.to_s
  end

  def each(list, &block)
    (list.blank? ? [] : list).each &block
  end
end
