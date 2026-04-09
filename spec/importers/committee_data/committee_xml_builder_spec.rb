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
      <COMPSTAGE>Completed</COMPSTAGE>
      <DTY_START>2024</DTY_START>
      <DTY_END>2026</DTY_END>
      <DSL_STUDENT>
        <FNAME>Test</FNAME>
        <LNAME>User</LNAME>
        <TITLE>Test Title</TITLE>
      </DSL_STUDENT>
    </DSL>
  </Record>
</Data>
'
      )
    end

    it 'omits DTY_END when completion year is nil' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Test',
        student_lname: 'User',
        role: 'Mentor',
        thesis_title: 'Test Title',
        type_of_work: 'Ph.D. Dissertation Committee',
        stage_of_completion: 'In Process',
        start_year: 2024,
        completion_year: nil
      )

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml).to include('<DTY_START>')
      expect(xml).not_to include('<DTY_END>')
      expect(xml).to include('<COMPSTAGE>In Process</COMPSTAGE>')
    end

    it 'handles faculty with no committees' do
      FactoryBot.create(:faculty, access_id: 'test123')

      result = xml_builder_obj.xmls_enumerator.to_a
      expect(result).to be_empty
    end

    it 'batches multiple faculty members with committees' do
      faculty1 = FactoryBot.create(:faculty, access_id: 'fac1')
      faculty2 = FactoryBot.create(:faculty, access_id: 'fac2')

      Committee.create!(faculty: faculty1, student_fname: 'John', student_lname: 'Doe', role: 'Mentor', thesis_title: 'Title 1')
      Committee.create!(faculty: faculty2, student_fname: 'Jane', student_lname: 'Smith', role: 'Chair', thesis_title: 'Title 2')

      result = xml_builder_obj.xmls_enumerator.to_a
      expect(result.length).to eq(1)
    end

    it 'handles faculty member with multiple committees' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(faculty: faculty, student_fname: 'John', student_lname: 'Doe', role: 'Mentor', thesis_title: 'Title 1')
      Committee.create!(faculty: faculty, student_fname: 'Jane', student_lname: 'Smith', role: 'Member', thesis_title: 'Title 2')

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml.scan('<DSL>').count).to eq(2)
    end
  end
end
