require 'nokogiri'
  
class PubXMLBuilder

  def xmls_enumerator
    Enumerator.new do |i|
      Faculty.joins(:publication_faculty_links).group('id').where.not(college: 'LA').find_in_batches(batch_size: 20) do |batch|
        i << build_xml(batch)
      end
    end
  end

  private

  def build_xml(batch)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.Data {
        batch.each do |faculty|
          xml.Record('username' => faculty.access_id) {
            faculty.publication_faculty_links.each do |link|
              xml.INTELLCONT {
                (link.publication.title.present?) ? xml.TITLE_(link.publication.title, :access => "READ_ONLY") : nil
                (link.publication.secondary_title.present?) ? xml.TITLE_SECONDARY_(link.publication.secondary_title, :access => "READ_ONLY") : nil
                (link.category.present?) ? xml.CONTYPE_(link.category, :access => "READ_ONLY") : nil
                (link.status.present?) ? xml.STATUS_(link.status, :access => "READ_ONLY") : nil
                (link.publication.journal_title.present?) ? xml.JOURNAL_NAME_(link.publication.journal_title, :access => "READ_ONLY") : nil
                (link.publication.volume.present?) ? xml.VOLUME_(link.publication.volume, :access => "READ_ONLY") : nil
                (link.publication.dty.present?) ? xml.DTY_PUB_(link.publication.dty, :access => "READ_ONLY") : nil
                (link.dtm.present?) ? xml.DTM_PUB_(link.dtm, :access => "READ_ONLY") : nil
                unless faculty.college == 'CM'
                  (link.publication.dtd.present?) ? xml.DTD_PUB_(link.publication.dtd, :access => "READ_ONLY") : nil
                end
                (link.publication.issue.present?) ? xml.ISSUE_(link.publication.issue, :access => "READ_ONLY") : nil
                (link.publication.edition.present?) ? xml.EDITION_(link.publication.edition, :access => "READ_ONLY") : nil
                (link.publication.abstract.present?) ? xml.ABSTRACT_(link.publication.abstract, :access => "READ_ONLY") : nil
                (link.publication.page_range.present?) ? xml.PAGENUM_(link.publication.page_range, :access => "READ_ONLY") : nil
                (link.publication.citation_count.present?) ? xml.CITATION_COUNT_(link.publication.citation_count, :access => "READ_ONLY") : nil
                (link.publication.authors_et_al.present?) ? xml.AUTHORS_ETAL_(link.publication.authors_et_al, :access => "READ_ONLY") : nil
                (link.publication.web_address.present?) ? xml.WEB_ADDRESS_(link.publication.web_address, :access => "READ_ONLY") : nil
                (link.publication.editors.present?) ? xml.EDITORS_(link.publication.editors, :access => "READ_ONLY") : nil
                (link.publication.institution.present?) ? xml.INSTITUTION_(link.publication.institution, :access => "READ_ONLY") : nil
                (link.publication.isbnissn.present?) ? xml.ISBNISSN_(link.publication.isbnissn, :access => "READ_ONLY") : nil
                (link.publication.pubctyst.present?) ? xml.PUBCTYST_(link.publication.pubctyst, :access => "READ_ONLY") : nil
                xml.INTELLCONT_AUTH_ { xml.FACULTY_NAME_ faculty.user_id, :access => "READ_ONLY" }
                link.publication.external_authors.each do |author|
                  xml.INTELLCONT_AUTH {
                    (author.f_name.present?) ? xml.FNAME_(author.f_name, :access => "READ_ONLY") : nil
                    (author.m_name.present?) ? xml.MNAME_(author.m_name, :access => "READ_ONLY") : nil
                    (author.l_name.present?) ? xml.LNAME_(author.l_name, :access => "READ_ONLY") : nil
                  }
                end
                (link.publication.pure_ids.present?) ? xml.PURE_ID_(link.publication.pure_ids) : nil
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end

end
