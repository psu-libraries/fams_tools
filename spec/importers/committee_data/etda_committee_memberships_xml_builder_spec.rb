require 'rails_helper'

RSpec.describe CommitteeData::EtdaCommitteeMembershipsXmlBuilder do
  describe '#to_xml' do
    it 'converts JSON payload to XML and normalizes role' do
      payload = {
        'faculty_access_id' => 'aab27',
        'committees' => [
          {
            'committee_member_id' => 101_388,
            'role' => 'Major Field Member',
            'role_code' => 'M',
            'student_fname' => 'Esther',
            'student_lname' => 'Munoz',
            'student_access_id' => 'ecm5494',
            'submission_id' => 22_620,
            'title' => 'Test Title',
            'degree_name' => 'PHD',
            'program_name' => 'Geosciences (PHD)',
            'semester' => 'Spring',
            'year' => 2025,
            'approval_started_at' => '2024-12-09T16:10:33.000-05:00',
            'final_submission_approved_at' => '2025-01-15T15:13:39.000-05:00',
            'submission_status' => 'released for publication metadata only',
            'committee_member_status' => 'approved'
          }
        ]
      }

      allow(CommitteeRoleNormalizer).to receive(:normalize)
        .with('Major Field Member')
        .and_return('Member')

      xml = described_class.new(payload).to_xml

      expect(xml).to include('<faculty_access_id>aab27</faculty_access_id>')
      expect(xml).to include('<committee_member_id>101388</committee_member_id>')
      expect(xml).to include('<role>Major Field Member</role>')
      expect(xml).to include('<normalized_role>Member</normalized_role>')
    end

    it 'raises when faculty_access_id missing' do
      payload = { 'committees' => [] }

      expect { described_class.new(payload).to_xml }
        .to raise_error(CommitteeData::EtdaCommitteeMembershipsXmlBuilder::ExportError)
    end
  end
end
