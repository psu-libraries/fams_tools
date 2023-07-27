require 'nokogiri'

class ComData::ComQualityXmlBuilder

  def xmls_enumerator_quality
    Enumerator.new do |i|
      Faculty.joins(:com_qualities).where("faculties.college = 'MD'").group('id')
      .find_in_batches(batch_size: 20) do |batch|
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
          faculty.com_qualities.each do |com_quality|
            xml.COURSE_EVAL {
              xml.COURSE_YEAR_ com_quality.course_year, :access => "READ_ONLY"
              xml.COURSE_NAME_ com_quality.course, :access => "READ_ONLY"
              xml.EVAL_NAME_ com_quality.event_type, :access => "READ_ONLY"
              xml.RATING_AVG_ com_quality.average_rating, :access => "READ_ONLY"
              xml.NUM_EVAL_ com_quality.num_evaluations, :access => "READ_ONLY"
            }
          end
          }
        end
      }
      end
      return builder.to_xml
  end

end
