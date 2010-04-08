module ModelSupport
  def each_zip_entry(data, &block)
    require 'java'
    require 'fileutils'

    stream = java.io.ByteArrayInputStream.new(data.to_java_bytes)
    zip = java.util.zip.ZipInputStream.new(stream)
    buffer = Java::byte[1024 * 1024].new

    loop do
      entry = zip.getNextEntry
      break if entry.nil?
      unless entry.directory?
        content = []
        while zip.available > 0 do
          n = zip.read(buffer);
          content << String.from_java_bytes(buffer[0...n]) if n > 0
        end
        yield entry.name, content.join('')
      end
    end
  end

  def parse_and_validate_date(attribute, value, min_year = 1000, max_year = 2999)
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
