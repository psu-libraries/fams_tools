require 'nokogiri'

class LionPathXMLBuilder

  def xmls_enumerator
    Enumerator.new do |i|
      Faculty.joins(:sections).group('id').find_in_batches(batch_size: 20) do |batch|
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
            faculty.sections.each do |section|
              xml.SCHTEACH {
                xml.TYT_TERM_ section.course.term, :access => "READ_ONLY"
                xml.TYY_TERM_ section.course.calendar_year, :access => "READ_ONLY"
                xml.TITLE_ section.course.course_short_description, :access => "READ_ONLY"
                xml.DESC_ section.course.course_long_description, :access => "READ_ONLY"
                xml.COURSEPRE_ section.subject_code, :access => "READ_ONLY"
                xml.COURSENUM_ section.course_number, :access => "READ_ONLY"
                xml.COURSENUM_SUFFIX_ section.course_suffix, :access => "READ_ONLY"
                xml.SECTION_ section.class_section_code, :access => "READ_ONLY"
                xml.CAMPUS_ section.class_campus_code, :access => "READ_ONLY"
                xml.ENROLL_ section.current_enrollment, :access => "READ_ONLY"
                xml.XCOURSE_COURSEPRE_ section.xcourse_course_pre, :access => "READ_ONLY"
                xml.XCOURSE_COURSENUM_ section.xcourse_course_num, :access => "READ_ONLY"
                xml.XCOURSE_COURSENUM_SUFFIX_ section.xcourse_course_suf, :access => "READ_ONLY"
                xml.RESPON_ section.instructor_load_factor, :access => "READ_ONLY"
                xml.CHOURS_ section.course_credits, :access => "READ_ONLY"
                xml.INST_MODE_ section.instruction_mode, :access => "READ_ONLY"
                xml.COURSE_COMP_ section.course_component, :access => "READ_ONLY"
                xml.ROLE_ section.instructor_role, :access => "READ_ONLY"
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end

end
