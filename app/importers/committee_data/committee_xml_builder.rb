require 'nokogiri'

class CommitteeData::CommitteeXmlBuilder
  def xmls_enumerator
    Enumerator.new do |i|
      Faculty.includes(:committees)
             .joins(:committees)
             .distinct
             .find_in_batches(batch_size: 20) do |batch|
        i << build_xml(batch)
      end
    end
  end

  private

  def build_xml(batch)
    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.Data do
        batch.each do |faculty|
          committees = faculty.committees
          next if committees.empty?

          xml.Record(username: faculty.access_id) do
            committees.each do |committee|
              xml.DSL do
                xml.ROLE committee.role, access: 'READ_ONLY'
                xml.ROLE_OTHER committee.role_other, access: 'READ_ONLY' if committee.role_other.present?
                xml.TYPE committee.type_of_work, access: 'READ_ONLY'
                xml.COMPSTAGE committee.stage_of_completion, access: 'READ_ONLY'

                same_date = committee.start_year == committee.completion_year &&
                            committee.start_month == committee.completion_month

                unless same_date
                  xml.DTM_START Date::MONTHNAMES[committee.start_month], access: 'READ_ONLY' if committee.start_month
                  xml.DTY_START committee.start_year, access: 'READ_ONLY' if committee.start_year
                end

                xml.DTM_END Date::MONTHNAMES[committee.completion_month], access: 'READ_ONLY' if committee.completion_month
                xml.DTY_END committee.completion_year, access: 'READ_ONLY' if committee.completion_year

                xml.DSL_STUDENT do
                  xml.FNAME committee.student_fname, access: 'READ_ONLY'
                  xml.LNAME committee.student_lname, access: 'READ_ONLY'
                  xml.DEG committee.degree_name, access: 'READ_ONLY' if committee.degree_name.present?
                  xml.TITLE committee.thesis_title, access: 'READ_ONLY'
                end
              end
            end
          end
        end
      end
    end
    builder.to_xml
  end
end
