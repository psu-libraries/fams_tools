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
                xml.ROLE_OTHER '' # TODO: add column later if needed
                xml.TYPE '' # e.g. "Other"
                xml.TYPE_OTHER '' # e.g. "Team Support"
                xml.COMPSTAGE '' # e.g. "Completed"

                # Student info block – one per committee for now
                xml.DSL_STUDENT do
                  xml.FNAME committee.student_fname
                  xml.LNAME committee.student_lname
                  xml.DEG committee.degree_type
                  xml.TITLE committee.thesis_title
                  xml.MAJOR ''
                  xml.DTM_GRAD ''
                  xml.DTD_GRAD ''
                  xml.DTY_GRAD ''
                end

                xml.COURSEPRE ''
                xml.COURSENUM ''
                xml.CHOURS ''
                xml.DTM_START ''
                xml.DTD_START ''
                xml.DTY_START ''
                xml.DTM_END ''
                xml.DTD_END ''
                xml.DTY_END ''

                xml.ABSTRACT ''
                xml.DETAILS ''
              end
            end
          end
        end
      end
    end

    builder.to_xml
  end
end
