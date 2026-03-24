require 'importers/importers_helper'

RSpec.describe CommitteeData::CommitteeXmlBuilder do
  let(:xml_builder_obj) { described_class.new }

  describe '#xmls_enumerator' do
    it 'returns an xml of DSL records with all Activity Insight fields' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Test',
        student_lname: 'User',
        role: 'Mentor',
        thesis_title: 'Test Title',
        degree_type: 'PhD',
        type_of_work: 'Ph.D. Dissertation Committee',
        stage_of_completion: 'Completed',
        start_year: 2024,
        completion_year: 2026
      )

      expect(xml_builder_obj.xmls_enumerator.first).to eq(
        '<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="test123">
    <DSL>
      <ROLE>Mentor</ROLE>
      <TYPE>Ph.D. Dissertation Committee</TYPE>
      <COMP>Completed</COMP>
      <DTY_START>2024</DTY_START>
      <DTY_END>2026</DTY_END>
      <DSL_STUDENT>
        <FNAME>Test</FNAME>
        <LNAME>User</LNAME>
        <DEG>PhD</DEG>
        <TITLE>Test Title</TITLE>
      </DSL_STUDENT>
    </DSL>
  </Record>
</Data>
'
      )
    end

    it 'omits DTY_START and DTY_END when years are nil' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Test',
        student_lname: 'User',
        role: 'Mentor',
        thesis_title: 'Test Title',
        degree_type: 'PhD',
        type_of_work: 'Ph.D. Dissertation Committee',
        stage_of_completion: 'In Process',
        start_year: nil,
        completion_year: nil
      )

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml).not_to include('<DTY_START>')
      expect(xml).not_to include('<DTY_END>')
      expect(xml).to include('<COMP>In Process</COMP>')
    end

    it 'includes ROLE_OTHER and TYPE_OTHER when role or type is Other' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Test',
        student_lname: 'User',
        role: 'Other',
        role_other_explanation: 'External International Reviewer',
        type_of_work: 'Other',
        type_other_explanation: 'Special Joint Program Committee',
        thesis_title: 'Research',
        degree_type: 'Special Degree'
      )

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml).to include('<ROLE>Other</ROLE>')
      expect(xml).to include('<ROLE_OTHER>External International Reviewer</ROLE_OTHER>')
      expect(xml).to include('<TYPE>Other</TYPE>')
      expect(xml).to include('<TYPE_OTHER>Special Joint Program Committee</TYPE_OTHER>')
    end

    it 'omits ROLE_OTHER and TYPE_OTHER when explanations are absent' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Test',
        student_lname: 'User',
        role: 'Advisor',
        thesis_title: 'Test Title',
        degree_type: 'PhD'
      )

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml).not_to include('<ROLE_OTHER>')
      expect(xml).not_to include('<TYPE_OTHER>')
    end

    it 'handles faculty with no committees' do
      FactoryBot.create(:faculty, access_id: 'test123')

      result = xml_builder_obj.xmls_enumerator.to_a
      expect(result).to be_empty
    end

    it 'batches multiple faculty members with committees' do
      faculty1 = FactoryBot.create(:faculty, access_id: 'fac1')
      faculty2 = FactoryBot.create(:faculty, access_id: 'fac2')

      Committee.create!(faculty: faculty1, student_fname: 'John', student_lname: 'Doe', role: 'Mentor', thesis_title: 'Title 1', degree_type: 'PhD')
      Committee.create!(faculty: faculty2, student_fname: 'Jane', student_lname: 'Smith', role: 'Chair', thesis_title: 'Title 2', degree_type: 'MS')

      result = xml_builder_obj.xmls_enumerator.to_a
      expect(result.length).to eq(1)
    end

    it 'handles faculty member with multiple committees' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(faculty: faculty, student_fname: 'John', student_lname: 'Doe', role: 'Mentor', thesis_title: 'Title 1', degree_type: 'PhD')
      Committee.create!(faculty: faculty, student_fname: 'Jane', student_lname: 'Smith', role: 'Member', thesis_title: 'Title 2', degree_type: 'MS')

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml.scan('<DSL>').count).to eq(2)
    end
  end
end
