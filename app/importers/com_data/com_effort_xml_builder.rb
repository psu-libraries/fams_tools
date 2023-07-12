require 'nokogiri'

class ComData::ComEffortXmlBuilder

  def xmls_enumerator_effort
    Enumerator.new do |i|
      ComCourse.group('com_id').find_in_batches(batch_size: 20) do |batch|
        i << build_xml_effort(batch)
      end
    end
  end

  private

  def build_xml_effort(batch)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.Data {
        batch.each do |faculty|
          xml.Record('PennStateHealthUsername' => faculty.com_id) {
            faculty.sections.each do |effort|
              xml.SCHTEACH {
                xml.COURSE_YEAR_ effort.course_year, :access => "READ_ONLY"
                xml.COURSE_TITLE_ effort.course, :access => "READ_ONLY"
                xml.EVENT_TITLE effort.event, :access => "READ_ONLY"
                xml.EVENT_TYPE_ effort.event_type, :access => "READ_ONLY"
                xml.EVENT_DATE_ effort.event_date, :access => "READ_ONLY"
                xml.CAL_TEACH_HRS_ effort.hours, :access => "READ_ONLY"
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end

end
