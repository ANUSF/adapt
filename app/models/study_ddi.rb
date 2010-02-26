module StudyDDI
  def to_ddi
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.codeBook(:version => "1.2.2") {
        docDscr(xml)
        stdyDscr(xml)
        fileDscr(xml)
        dataDscr(xml)
      }
    end
  end

  private
  def docDscr(xml)
    xml.docDscr  { 
      xml.citation {
        xml.titlStmt {
          xml.titl title
        }
        xml.prodStmt
        xml.verStmt
      }
    }
  end
  
  def stdyDscr(xml)
    xml.stdyDscr {
      xml.citation {
        xml.titlStmt {
          xml.titl title
        }
        xml.rspStmt
        xml.prodStmt
        xml.distStmt
        xml.serStmt
        xml.verStmt
        xml.biblCit
      }
      stdyInfo(xml)
    }
  end

  def stdyInfo(xml)
    xml.stdyInfo {
      xml.subject
      xml.abstract abstract
    }
  end

  def fileDscr(xml)
  end

  def dataDscr(xml)
  end
end
