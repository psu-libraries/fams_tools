require 'json'
require 'builder'

class CommitteeData::EtdaCommitteeMembershipsXmlBuilder
  class ExportError < StandardError; end

  def initialize(payload)
    @payload = payload.is_a?(String) ? JSON.parse(payload) : payload
  rescue JSON::ParserError => e
    raise ExportError, "Invalid JSON: #{e.message}"
  end

  def to_xml
    validate_payload!
    faculty_access_id = @payload.fetch('faculty_access_id').to_s
    committees = @payload.fetch('committees')
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')

    xml.faculty_committees do
      xml.faculty_access_id faculty_access_id

      xml.committees do
        committees.each do |row|
          build_committee(xml, row)
        end
      end
    end
    xml.target!
  end

  private

  def validate_payload!
    raise ExportError, 'Payload must be a JSON object' unless @payload.is_a?(Hash)
    raise ExportError, 'faculty_access_id is required' if @payload['faculty_access_id'].to_s.strip.empty?
    return if @payload['committees'].is_a?(Array)

    raise ExportError, 'committees must be an array'
  end

  def build_committee(xml, row)
    raise ExportError, 'Each committee must be an object' unless row.is_a?(Hash)

    raw_role = row['role']
    normalized_role = CommitteeRoleNormalizer.normalize(raw_role)
    xml.committee do
      xml.committee_member_id row['committee_member_id']
      xml.role raw_role
      xml.normalized_role normalized_role
      xml.role_code row['role_code']
      xml.student do
        xml.fname row['student_fname']
        xml.lname row['student_lname']
        xml.access_id row['student_access_id']
      end
      xml.submission do
        xml.submission_id row['submission_id']
        xml.title row['title']
        xml.degree_name row['degree_name']
        xml.program_name row['program_name']
        xml.semester row['semester']
        xml.year row['year']
        xml.status row['submission_status']
        xml.final_submission_approved_at row['final_submission_approved_at']
      end
      xml.approval_started_at row['approval_started_at']
      xml.committee_member_status row['committee_member_status']
    end
  end
end
