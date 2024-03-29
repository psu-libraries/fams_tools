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
    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.Data do
        batch.each do |faculty|
          departments_added = []
          xml.Record('username' => faculty.access_id) do
            faculty.yearlies.each do |yearly|
              xml.ADMIN do
                xml.AC_YEAR(yearly.academic_year)
                xml.CAMPUS(yearly.campus)
                xml.CAMPUS_NAME(yearly.campus_name)
                xml.COLLEGE(yearly.college)
                xml.COLLEGE_NAME(yearly.college_name)
                xml.SCHOOL(yearly.school)
                xml.DIVISION(yearly.division)
                xml.INSTITUTE(yearly.institute)
                6.times do |i|
                  break unless yearly.departments.keys.any? { |k| k.include?((i + 1).to_s) }

                  dep = nil
                  dep_other = nil
                  yearly.departments.keys.each do |key|
                    dep = key if key.include?((i + 1).to_s) && !key.include?('OTHER')
                    dep_other = key if key.include?((i + 1).to_s) && key.include?('OTHER')
                  end
                  unless (dep.present? || dep_other.present?) && !(departments_added.include?(yearly.departments[dep]) || departments_added.include?(yearly.departments[dep_other]))
                    next
                  end

                  xml.ADMIN_DEP do
                    xml.DEP(yearly.departments[dep])
                    xml.DEP_OTHER(yearly.departments[dep_other])
                  end
                  departments_added << yearly.departments[dep] if dep.present?
                  departments_added << yearly.departments[dep_other] if dep.present?
                end
                xml.TITLE(yearly.title)
                xml.RANK(yearly.rank)
                xml.TENURE(yearly.tenure)
                xml.ENDPOS(yearly.endowed_position)
                xml.GRADUATE(yearly.graduate)
                xml.TIME_STATUS(yearly.time_status)
                xml.HR_CODE(yearly.hr_code)
              end
            end
          end
        end
      end
    end
    builder.to_xml
  end
end
