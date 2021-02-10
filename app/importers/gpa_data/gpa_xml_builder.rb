class GpaXmlBuilder

  def xmls_enumerator
    Enumerator.new do |i|
      Faculty.joins(:gpas).group('id').where(college: 'LA').find_in_batches(batch_size: 20) do |batch|
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
            faculty.gpas.each do |gpa|
              xml.GRADE_DIST_GPA {
                xml.TYT_TERM(gpa.semester)
                xml.TYY_TERM(gpa.year)
                xml.COURSEPRE(gpa.course_prefix)
                xml.COURSENUM(gpa.course_number)
                xml.COURSENUM_SUFFIX(gpa.course_number_suffix)
                xml.SECTION(gpa.section_number)
                xml.CAMPUS(gpa.campus)
                xml.NUMGRADES(gpa.number_of_grades)
                xml.STEARNA(gpa.grade_dist_a)
                xml.STEARNAMINUS(gpa.grade_dist_a_minus)
                xml.STEARNBPLUS(gpa.grade_dist_b_plus)
                xml.STEARNB(gpa.grade_dist_b)
                xml.STEARNBMINUS(gpa.grade_dist_b_minus)
                xml.STEARNCPLUS(gpa.grade_dist_c_plus)
                xml.STEARNC(gpa.grade_dist_c)
                xml.STEARND(gpa.grade_dist_d)
                xml.STEARNF(gpa.grade_dist_f)
                xml.STEARNW(gpa.grade_dist_w)
                xml.STEARNL(gpa.grade_dist_ld)
                xml.STEARNOTHER(gpa.grade_dist_other)
                xml.GPA(gpa.course_gpa)
            }
            end
          }
        end
      }
    end
    return builder.to_xml
  end
end
