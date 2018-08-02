require 'nokogiri'
  
class PureXMLBuilder
  attr_accessor :faculties

  def initialize
    @faculties = Faculty.joins(:publications).group('id').where.not(college: ['LA'])
  end

  def batched_xmls
    xml_batches = []
    faculties.each_slice(2) do |batch|
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
                xml.TITLE_ publication.title, :access => "READ_ONLY"
                xml.CONTYPE_ publication.category, :access => "READ_ONLY"
                xml.STATUS_ publication.status, :access => "READ_ONLY"
                xml.JOURNAL_NAME_ publication.journal_title, :access => "READ_ONLY"
                xml.ISBNISSN_ publication.journal_issn, :access => "READ_ONLY"
                xml.VOLUME_ publication.volume, :access => "READ_ONLY"
                xml.DTY_PUB_ publication.dty, :access => "READ_ONLY"
                xml.DTM_PUB_ publication.dtm, :access => "READ_ONLY"
                unless faculty.college == 'CM'
                  xml.DTD_PUB_ publication.dtd, :access => "READ_ONLY"
                end
                xml.ISSUE_ publication.journal_num, :access => "READ_ONLY"
                xml.PAGENUM_ publication.pages, :access => "READ_ONLY"
                publication.external_authors.each do |author|
                  xml.INTELLCONT_AUTH {
                    xml.FNAME_ author.f_name, :access => "READ_ONLY"
                    xml.MNAME_ author.m_name, :access => "READ_ONLY"
                    xml.LNAME_ author.l_name, :access => "READ_ONLY"
                    xml.ROLE_ author.role, :access => "READ_ONLY"
                    xml.INSTITUTION_ author.extOrg, :access => "READ_ONLY"
                  }
                end
                xml.PUBLISHER_ publication.publisher, :access => "READ_ONLY"
                xml.WEB_ADDRESS_ publication.url, :access => "READ_ONLY"
                xml.REFEREED_ publication.peerReview, :access => "READ_ONLY"
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end

end
