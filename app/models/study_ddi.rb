require 'nokogiri'

module StudyDDI
  def to_ddi
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.codeBook(:version => "1.2.2") {
        xml.docDscr {
        }
        xml.stdyDscr {
        }
        xml.fileDscr {
        }
        xml.dataDscr {
        }
      }
    end
  end
end
