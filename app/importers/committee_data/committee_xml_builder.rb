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
                xml.ROLE committee.role
                xml.ROLE_OTHER committee.role_other_explanation if committee.role_other_explanation.present?
                xml.TYPE committee.type_of_work
                xml.TYPE_OTHER committee.type_other_explanation if committee.type_other_explanation.present?
                xml.COMPSTAGE committee.stage_of_completion
                xml.DTY_START committee.start_year if committee.start_year
                xml.DTY_END committee.completion_year if committee.completion_year

                xml.DSL_STUDENT do
                  xml.FNAME committee.student_fname
                  xml.LNAME committee.student_lname
                  xml.DEG committee.degree_type
                  xml.TITLE committee.thesis_title
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
