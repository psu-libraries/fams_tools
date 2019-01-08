require 'nokogiri'
  
class PubXMLBuilder
  attr_accessor :faculties

  def initialize
    @faculties = Faculty.joins(:publication_faculty_links).group('id').where.not(college: 'LA')
  end

  def batched_xmls
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
            faculty.publication_faculty_links.each do |link|
              xml.INTELLCONT {
                (link.publication.title != nil) ? xml.TITLE_(link.publication.title, :access => "READ_ONLY") : nil
                (link.publication.secondary_title != nil) ? xml.TITLE_SECONDARY_(link.publication.secondary_title, :access => "READ_ONLY") : nil
                (link.category != nil) ? xml.CONTYPE_(link.category, :access => "READ_ONLY") : nil
                (link.status != nil) ? xml.STATUS_(link.status, :access => "READ_ONLY") : nil
                (link.publication.journal_title != nil) ? xml.JOURNAL_NAME_(link.publication.journal_title, :access => "READ_ONLY") : nil
                (link.publication.volume != nil) ? xml.VOLUME_(link.publication.volume, :access => "READ_ONLY") : nil
                (link.publication.dty != nil) ? xml.DTY_PUB_(link.publication.dty, :access => "READ_ONLY") : nil
                (link.dtm != nil) ? xml.DTM_PUB_(link.dtm, :access => "READ_ONLY") : nil
                unless faculty.college == 'CM'
                  (link.publication.dtd != nil) ? xml.DTD_PUB_(link.publication.dtd, :access => "READ_ONLY") : nil
                end
                (link.publication.issue != nil) ? xml.ISSUE_(link.publication.issue, :access => "READ_ONLY") : nil
                (link.publication.edition != nil) ? xml.EDITION_(link.publication.edition, :access => "READ_ONLY") : nil
                (link.publication.abstract != nil) ? xml.ABSTRACT_(link.publication.abstract, :access => "READ_ONLY") : nil
                (link.publication.page_range != nil) ? xml.PAGENUM_(link.publication.page_range, :access => "READ_ONLY") : nil
                (link.publication.citation_count != nil) ? xml.CITATION_COUNT_(link.publication.citation_count, :access => "READ_ONLY") : nil
                (link.publication.authors_et_al != nil) ? xml.AUTHORS_ETAL_(link.publication.authors_et_al, :access => "READ_ONLY") : nil
                (link.publication.web_address != nil) ? xml.WEB_ADDRESS_(link.publication.web_address, :access => "READ_ONLY") : nil
                (link.publication.editors != nil) ? xml.EDITORS_(link.publication.editors, :access => "READ_ONLY") : nil
                (link.publication.institution != nil) ? xml.INSTITUTION_(link.publication.institution, :access => "READ_ONLY") : nil
                (link.publication.isbnissn != nil) ? xml.ISBNISSN_(link.publication.isbnissn, :access => "READ_ONLY") : nil
                (link.publication.pubctyst != nil) ? xml.PUBCTYST_(link.publication.pubctyst, :access => "READ_ONLY") : nil
                xml.INTELLCONT_AUTH_ { xml.FACULTY_NAME_ faculty.user_id, :access => "READ_ONLY" }
                link.publication.external_authors.each do |author|
                  xml.INTELLCONT_AUTH {
                    (author.f_name != nil) ? xml.FNAME_(author.f_name, :access => "READ_ONLY") : nil
                    (author.m_name != nil) ? xml.MNAME_(author.m_name, :access => "READ_ONLY") : nil
                    (author.l_name != nil) ? xml.LNAME_(author.l_name, :access => "READ_ONLY") : nil
                  }
                end
                (link.publication.pure_ids != nil) ? xml.PURE_ID_(link.publication.pure_ids) : nil
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end

end
