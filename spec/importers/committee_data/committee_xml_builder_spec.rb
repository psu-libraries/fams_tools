require 'importers/importers_helper'

RSpec.describe CommitteeData::CommitteeXmlBuilder do
  let(:xml_builder_obj) { described_class.new }
  describe '#xmls_enumerator' do
    it 'returns an xml of DSL records' do
      faculty = FactoryBot.create(:faculty, access_id: 'test123')

      Committee.create!(
        faculty: faculty,
        student_fname: 'Test',
        student_lname: 'User',
        role: 'Mentor',
        thesis_title: 'Test Title',
        degree_type: 'PhD'    
      )

      expect(xml_builder_obj.xmls_enumerator.first).to eq(
        '<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="test123">
    <DSL>
      <ROLE>Mentor</ROLE>
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
end
end