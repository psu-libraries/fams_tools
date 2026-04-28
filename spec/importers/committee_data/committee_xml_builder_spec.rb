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
        start_month: 8,
        completion_year: 2026,
        completion_month: 1
      )

      expect(xml_builder_obj.xmls_enumerator.first).to eq(
        '<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="test123">
    <DSL>
      <ROLE access="READ_ONLY">Mentor</ROLE>
      <TYPE access="READ_ONLY">Ph.D. Dissertation Committee</TYPE>
      <COMPSTAGE access="READ_ONLY">Completed</COMPSTAGE>
      <DTM_START access="READ_ONLY">August</DTM_START>
      <DTY_START access="READ_ONLY">2024</DTY_START>
      <DTM_END access="READ_ONLY">January</DTM_END>
      <DTY_END access="READ_ONLY">2026</DTY_END>
      <DSL_STUDENT>
        <FNAME access="READ_ONLY">Test</FNAME>
        <LNAME access="READ_ONLY">User</LNAME>
        <TITLE access="READ_ONLY">Test Title</TITLE>
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
      expect(xml).to include('<DTY_START access="READ_ONLY">')
      expect(xml).not_to include('<DTY_END')
      expect(xml).to include('<COMPSTAGE access="READ_ONLY">In Process</COMPSTAGE>')
    end

    it 'emits only end-date tags when start and end dates are the same year and month' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Test',
        student_lname: 'User',
        role: 'Mentor',
        thesis_title: 'Test Title',
        start_year: 2025,
        start_month: 3,
        completion_year: 2025,
        completion_month: 3
      )

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml).not_to include('<DTM_START')
      expect(xml).not_to include('<DTY_START')
      expect(xml).to include('<DTM_END access="READ_ONLY">March</DTM_END>')
      expect(xml).to include('<DTY_END access="READ_ONLY">2025</DTY_END>')
    end

    it 'emits all four date tags when year matches but months differ' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Test',
        student_lname: 'User',
        role: 'Mentor',
        thesis_title: 'Test Title',
        start_year: 2025,
        start_month: 3,
        completion_year: 2025,
        completion_month: 11
      )

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml).to include('<DTM_START access="READ_ONLY">March</DTM_START>')
      expect(xml).to include('<DTY_START access="READ_ONLY">2025</DTY_START>')
      expect(xml).to include('<DTM_END access="READ_ONLY">November</DTM_END>')
      expect(xml).to include('<DTY_END access="READ_ONLY">2025</DTY_END>')
    end

    it 'emits all four date tags when years differ' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Test',
        student_lname: 'User',
        role: 'Mentor',
        thesis_title: 'Test Title',
        start_year: 2024,
        start_month: 8,
        completion_year: 2026,
        completion_month: 1
      )

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml).to include('<DTM_START access="READ_ONLY">August</DTM_START>')
      expect(xml).to include('<DTY_START access="READ_ONLY">2024</DTY_START>')
      expect(xml).to include('<DTM_END access="READ_ONLY">January</DTM_END>')
      expect(xml).to include('<DTY_END access="READ_ONLY">2026</DTY_END>')
    end

    it 'emits only DTY_END when months are nil and years are the same' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Test',
        student_lname: 'User',
        role: 'Mentor',
        thesis_title: 'Test Title',
        start_year: 2025,
        start_month: nil,
        completion_year: 2025,
        completion_month: nil
      )

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml).not_to include('<DTM_START')
      expect(xml).not_to include('<DTY_START')
      expect(xml).not_to include('<DTM_END')
      expect(xml).to include('<DTY_END access="READ_ONLY">2025</DTY_END>')
    end

    it 'emits both years and no month tags when months are nil and years differ' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Test',
        student_lname: 'User',
        role: 'Mentor',
        thesis_title: 'Test Title',
        start_year: 2024,
        start_month: nil,
        completion_year: 2026,
        completion_month: nil
      )

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml).to include('<DTY_START access="READ_ONLY">2024</DTY_START>')
      expect(xml).to include('<DTY_END access="READ_ONLY">2026</DTY_END>')
      expect(xml).not_to include('<DTM_START')
      expect(xml).not_to include('<DTM_END')
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

    it 'emits ROLE_OTHER when role is Other and role_other is present' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Jane',
        student_lname: 'Doe',
        role: 'Other',
        role_other: 'Support Faculty',
        thesis_title: 'Some Title',
        type_of_work: 'Dissertation Committee',
        stage_of_completion: 'In Process',
        start_year: 2025,
        start_month: 1
      )

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml).to include('<ROLE access="READ_ONLY">Other</ROLE>')
      expect(xml).to include('<ROLE_OTHER access="READ_ONLY">Support Faculty</ROLE_OTHER>')
    end

    it 'does not emit ROLE_OTHER when role_other is blank' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Jane',
        student_lname: 'Doe',
        role: 'Mentor',
        role_other: nil,
        thesis_title: 'Some Title',
        type_of_work: 'Dissertation Committee',
        stage_of_completion: 'In Process',
        start_year: 2025,
        start_month: 1
      )

      xml = xml_builder_obj.xmls_enumerator.first
      expect(xml).not_to include('<ROLE_OTHER')
    end
  end
end
