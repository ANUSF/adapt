module StudiesHelper
  def date(date_string)
    date = begin Date.parse(date_string.to_s.strip) rescue nil end
    date.to_s
  end
end
