require 'nokogiri'

class ComData::ComEffortXmlBuilder

  def xmls_enumerator_effort
    Enumerator.new do |i|
      Faculty.joins(:com_efforts).where("faculties.college = 'MD'").group('id')
      .find_in_batches(batch_size: 20) do |batch|
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
            faculty.com_efforts.each do |com_effort|
              xml.INSTRUCT_TAUGHT {
                xml.COURSE_YEAR_ com_effort.course_year, :access => "READ_ONLY"
                xml.COURSE_TITLE_ com_effort.course, :access => "READ_ONLY"
                xml.EVENT_TITLE_ com_effort.event, :access => "READ_ONLY"
                xml.EVENT_TYPE_ com_effort.event_type, :access => "READ_ONLY"
                xml.CAL_TEACH_HRS_ com_effort.hours, :access => "READ_ONLY"
              }
            end
          }
          end
      }
      end
      return builder.to_xml
  end

end
