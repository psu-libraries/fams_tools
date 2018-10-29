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
                xml.TITLE_ link.publication.title, :access => "READ_ONLY"
                xml.TITLE_ link.publication.secondary_title, :access => "READ_ONLY"
                xml.CONTYPE_ link.category, :access => "READ_ONLY"
                xml.STATUS_ link.status, :access => "READ_ONLY"
                xml.JOURNAL_NAME_ link.publication.journal_title, :access => "READ_ONLY"
                xml.VOLUME_ link.publication.volume, :access => "READ_ONLY"
                xml.DTY_PUB_ link.publication.dty, :access => "READ_ONLY"
                xml.DTM_PUB_ link.dtm, :access => "READ_ONLY"
                unless faculty.college == 'CM'
                  xml.DTD_PUB_ link.publication.dtd, :access => "READ_ONLY"
                end
                xml.ISSUE_ link.publication.issue, :access => "READ_ONLY"
                xml.EDITION_ link.publication.edition, :access => "READ_ONLY"
                xml.ABSTRACT_ link.publication.abstract, :access => "READ_ONLY"
                xml.PAGENUM_ link.publication.page_range, :access => "READ_ONLY"
                xml.CITATION_COUNT_ link.publication.citation_count, :access => "READ_ONLY"
                xml.AUTHORS_ETAL_ link.publication.authors_et_al, :access => "READ_ONLY"
                link.publication.external_authors.each do |author|
                  xml.INTELLCONT_AUTH {
                    xml.FNAME_ author.f_name, :access => "READ_ONLY"
                    xml.MNAME_ author.m_name, :access => "READ_ONLY"
                    xml.LNAME_ author.l_name, :access => "READ_ONLY"
                  }
                end
                xml.PURE_ID_ link.publication.pure_ids
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end

end
