require 'nokogiri'

class ComData::ComQualityXmlBuilder

  def xmls_enumerator_quality
    Enumerator.new do |i|
      ComCourse.group('com_id').find_in_batches(batch_size: 20) do |batch|
        i << build_xml_quality(batch)
      end
    end
  end

  private

  def build_xml_quality(batch)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.Data {
        batch.each do |faculty|
          xml.Record('PennStateHealthUsername' => faculty.com_id) {
            faculty.sections.each do |quality|
              xml.SCHTEACH {
                xml.COURSE_YEAR_ quality.course_year, :access => "READ_ONLY"
                xml.COURSE_NAME_ quality.course, :access => "READ_ONLY"
                xml.EVAL_NAME_ quality.event_type, :access => "READ_ONLY"
                xml.EVAL_TYPE_ quality.evaluation_type, :access => "READ_ONLY"
                xml.RATING_AVG_ quality.average_rating, :access => "READ_ONLY"
                xml.NUM_EVAL_ quality.num_evaluations, :access => "READ_ONLY"
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end

end
