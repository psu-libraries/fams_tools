require 'nokogiri'
  
class PureXMLBuilder
  attr_accessor :faculties

  def initialize
    @faculties = Faculty.joins(:publications).group('id')
  end

  def batched_pure_xml
    xml_batches = []
    faculties.each_slice(20) do |batch|
      xml_batches << build_xml(batch)
    end
    return xml_batches
  end

  private

  def build_xml(batch)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.Data {
        batch.each do |faculty|
          xml.Record('username' => faculty.access_id) {
            faculty.publications.each do |publication|
              xml.INTELLCONT {
                xml.TITLE_ publication.title, :access => "READ ONLY"
                xml.CONTYPE_ publication.category, :access => "READ ONLY"
                xml.STATUS_ publication.status, :access => "READ ONLY"
                xml.JOURNAL_NAME_ publication.journal_title, :access => "READ ONLY"
                xml.ISBNISSN_ publication.journal_issn, :access => "READ ONLY"
                xml.VOLUME_ publication.volume, :access => "READ ONLY"
                xml.DTY_PUB_ publication.dty, :access => "READ ONLY"
                xml.DTM_PUB_ publication.dtm, :access => "READ ONLY"
                xml.DTD_PUB_ publication.dtd, :access => "READ ONLY"
                xml.ISSUE_ publication.journal_num, :access => "READ ONLY"
                xml.PAGENUM_ publication.pages, :access => "READ ONLY"
                publication.external_authors.each do |author|
                  xml.INTELLCONT_AUTH {
                    xml.FNAME_ author.f_name, :access => "READ ONLY"
                    xml.MNAME_ author.m_name, :access => "READ ONLY"
                    xml.LNAME_ author.l_name, :access => "READ ONLY"
                    xml.ROLE_ author.role, :access => "READ ONLY"
                    xml.INSTITUTION_ author.extOrg, :access => "READ ONLY"
                  }
                end
                xml.WEB_ADDRESS_ publication.url, :access => "READ ONLY"
                xml.REFEREED_ publication.peerReview, :access => "READ ONLY"
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end

end
