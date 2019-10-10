class GpaXmlBuilder
  def initialize
    @faculties = Faculty.joins(:gpas).group('id')
  end

  def batched_xmls
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
            faculty.gpas.each do |gpa|
              xml.GRADE_DIST_GPA {
                (gpa.semester != nil) ? xml.TYT_TERM(gpa.semester) : nil
                (gpa.year != nil) ? xml.TYY_TERM(gpa.year) : nil
                (gpa.course_prefix != nil) ? xml.COURSEPRE(gpa.course_prefix) : nil
                (gpa.course_number != nil) ? xml.COURSENUM(gpa.course_number) : nil
                (gpa.course_number_suffix != nil) ? xml.COURSENUM_SUFFIX(gpa.course_number_suffix) : nil
                (gpa.section_number != nil) ? xml.SECTION(gpa.section_number) : nil
                (gpa.campus != nil) ? xml.CAMPUS(gpa.campus) : nil
                (gpa.number_of_grades != nil) ? xml.NUMGRADES(gpa.number_of_grades) : nil
                (gpa.grade_dist_a != nil) ? xml.STEARNA(gpa.grade_dist_a) : nil
                (gpa.grade_dist_a_minus != nil) ? xml.STEARNAMINUS(gpa.grade_dist_a_minus) : nil
                (gpa.grade_dist_b_plus != nil) ? xml.STEARNBPLUS(gpa.grade_dist_b_plus) : nil
                (gpa.grade_dist_b != nil) ? xml.STEARNB(gpa.grade_dist_b) : nil
                (gpa.grade_dist_b_minus != nil) ? xml.STEARNBMINUS(gpa.grade_dist_b_minus) : nil
                (gpa.grade_dist_c_plus != nil) ? xml.STEARNCPLUS(gpa.grade_dist_c_plus) : nil
                (gpa.grade_dist_c != nil) ? xml.STEARNC(gpa.grade_dist_c) : nil
                (gpa.grade_dist_d != nil) ? xml.STEARND(gpa.grade_dist_d) : nil
                (gpa.grade_dist_f != nil) ? xml.STEARNF(gpa.grade_dist_f) : nil
                (gpa.grade_dist_w != nil) ? xml.STEARNW(gpa.grade_dist_w) : nil
                (gpa.grade_dist_ld != nil) ? xml.STEARNL(gpa.grade_dist_ld) : nil
                (gpa.grade_dist_other != nil) ? xml.STEARNOTHER(gpa.grade_dist_other) : nil
                (gpa.course_gpa != nil) ? xml.GPA(gpa.course_gpa) : nil
            }
            end
          }
        end
      }
    end
    return builder.to_xml
  end
end
