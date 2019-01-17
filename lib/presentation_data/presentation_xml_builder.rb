require 'nokogiri'
  
class PresentationXMLBuilder
  attr_accessor :faculties

  def initialize
    @faculties = Faculty.joins(:presentations).group('id')
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
            faculty.presentations.each do |presentation|
              xml.PRESENT {
                (presentation.title.present?) ? xml.TITLE_(presentation.title, :access => "READ_ONLY") : nil
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
