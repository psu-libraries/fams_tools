class YearlyData::YearlyXmlBuilder

  def xmls_enumerator
    Enumerator.new do |i|
      Faculty.joins(:yearlies).group('id').find_in_batches(batch_size: 20) do |batch|
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
              faculty.yearlies.each do |yearly|
                xml.ADMIN {
                  xml.AC_YEAR(yearly.academic_year)
                  xml.CAMPUS(yearly.campus)
                  xml.CAMPUS_NAME(yearly.campus_name)
                  xml.COLLEGE(yearly.college)
                  xml.COLLEGE_NAME(yearly.college_name)
                  xml.SCHOOL(yearly.school)
                  xml.DIVISION(yearly.division)
                  xml.INSTITUTE(yearly.institute)
                  xml.ADMIN_DEP_1_DEP(yearly.admin_dept1)
                  xml.ADMIN_DEP_1_DEP_OTHER(yearly.admin_dept1_other)
                  xml.ADMIN_DEP_2_DEP(yearly.admin_dept2)
                  xml.ADMIN_DEP_2_DEP_OTHER(yearly.admin_dept2_other)
                  xml.ADMIN_DEP_3_DEP(yearly.admin_dept3)
                  xml.ADMIN_DEP_3_DEP_OTHER(yearly.admin_dept3_other)
                  xml.TITLE(yearly.title)
                  xml.RANK(yearly.rank)
                  xml.TENURE(yearly.tenure)
                  xml.ENDPOS(yearly.endowed_position)
                  xml.GRADUATE(yearly.graduate)
                  xml.TIME_STATUS(yearly.time_status)
                  xml.HR_CODE(yearly.hr_code)
                }
              end
            }
          end
        }
      end
      return builder.to_xml
    end
end
  