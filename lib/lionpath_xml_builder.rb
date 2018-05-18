require 'nokogiri'

class LionPathXMLBuilder
  def initialize
    @faculties = Faculty.joins(:sections).group('access_id')
  end

  def batched_lionpath_xml
    xml_batches = []
    @faculties.each_slice(20) do |batch|
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
            faculty.sections.each do |section|
              xml.SCHTEACH {
                xml.TYT_TERM_ section.course.term, :access => "LOCKED"
                xml.TYY_TERM_ section.course.calendar_year, :access => "LOCKED"
                xml.TITLE_ section.course.course_short_description, :access => "LOCKED"
                xml.DESC_ section.course.course_long_description, :access => "LOCKED"
                xml.COURSEPRE_ section.subject_code, :access => "LOCKED"
                xml.COURSENUM_ section.course_number, :access => "LOCKED"
                xml.COURSENUM_SUFFIX_ section.course_suffix, :access => "LOCKED"
                xml.SECTION_ section.class_section_code, :access => "LOCKED"
                xml.CAMPUS_ section.class_campus_code, :access => "LOCKED"
                xml.ENROLL_ section.current_enrollment, :access => "LOCKED"
                xml.XCOURSE_COURSEPRE_ section.xcourse_course_pre, :access => "LOCKED"
                xml.XCOURSE_COURSENUM_ section.xcourse_course_num, :access => "LOCKED"
                xml.XCOURSE_COURSENUM_SUFFIX_ section.xcourse_course_suf, :access => "LOCKED"
                xml.RESPON_ section.instructor_load_factor, :access => "LOCKED"
                xml.CHOURS_ section.course_credits, :access => "LOCKED"
                xml.INST_MODE_ section.instruction_mode, :access => "LOCKED"
                xml.COURSE_COMP_ section.course_component, :access => "LOCKED"
              }
            end
          }
        end
      }
    end
    return builder.to_xml
  end

end
