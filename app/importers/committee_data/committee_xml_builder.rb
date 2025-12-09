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
          next if faculty.committees.empty?

          xml.Record('username' => faculty.access_id) do
            faculty.committees.each do |committee|
              xml.COMMITTEE do
                xml.STUDENT_FNAME_ committee.student_fname
                xml.STUDENT_MNAME_ committee.student_mname
                xml.STUDENT_LNAME_ committee.student_lname
                xml.ROLE_          committee.role
                xml.THESIS_TITLE_  committee.thesis_title
                xml.DEGREE_TYPE_   committee.degree_type
              end
            end
          end
        end
      end
    end
    builder.to_xml
  end
end
