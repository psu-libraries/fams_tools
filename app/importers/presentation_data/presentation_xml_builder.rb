require 'nokogiri'
  
class PresentationXMLBuilder

  def xmls_enumerator
    Enumerator.new do |i|
      Faculty.joins(:presentations).group('id').find_in_batches(batch_size: 20) do |batch|
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
            faculty.presentations.each do |presentation|
              xml.PRESENT {
                (presentation.title.present?) ? xml.TITLE_(presentation.title.gsub(/[^[:print:]]/,''), :access => "READ_ONLY") : nil
                (presentation.dty_date.present?) ? xml.DTY_END_(presentation.dty_date, :access => "READ_ONLY") : nil
                (presentation.name.present?) ? xml.NAME_(presentation.name, :access => "READ_ONLY") : nil
                (presentation.org.present?) ? xml.ORG_(presentation.org, :access => "READ_ONLY") : nil
                (presentation.location.present?) ? xml.LOCATION_(presentation.location, :access => "READ_ONLY") : nil
                xml.PRESENT_AUTH_ { xml.FACULTY_NAME_ faculty.user_id }
                presentation.presentation_contributors.each do |contributor|
                  xml.PRESENT_AUTH {
                    (contributor.f_name.present?) ? xml.FNAME_(contributor.f_name, :access => "READ_ONLY") : nil
                    (contributor.m_name.present?) ? xml.MNAME_(contributor.m_name, :access => "READ_ONLY") : nil
                    (contributor.l_name.present?) ? xml.LNAME_(contributor.l_name, :access => "READ_ONLY") : nil
                  }
                end
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end
end
