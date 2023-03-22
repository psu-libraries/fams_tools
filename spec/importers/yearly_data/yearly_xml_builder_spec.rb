require 'importers/importers_helper'

RSpec.describe YearlyData::YearlyXmlBuilder do

  let!(:faculty1) { FactoryBot.create :faculty}
  let!(:faculty2) { FactoryBot.create :faculty, access_id: 'def123'}
  let!(:yearly1) { FactoryBot.create :yearly, faculty: faculty1 }
  let!(:yearly2) { FactoryBot.create :yearly, faculty: faculty2, school: 'Other School', division: 'Other Division' }
  let(:xml_builder_obj) { described_class.new }

  describe "#batched_yearly_xmls" do
    it "should return an array of yearly data xmls" do
      expect(xml_builder_obj.xmls_enumerator.first).to eq(
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Data>
  <Record username=\"#{faculty1.access_id}\">
    <ADMIN>
      <AC_YEAR>2023-2024</AC_YEAR>
      <CAMPUS>UP</CAMPUS>
      <CAMPUS_NAME>University Park</CAMPUS_NAME>
      <COLLEGE>EN</COLLEGE>
      <COLLEGE_NAME>College of Engineering</COLLEGE_NAME>
      <SCHOOL>School</SCHOOL>
      <DIVISION>Division</DIVISION>
      <INSTITUTE>Institute</INSTITUTE>
      <ADMIN_DEP_1_DEP>Dept 1</ADMIN_DEP_1_DEP>
      <ADMIN_DEP_1_DEP_OTHER>Other 1</ADMIN_DEP_1_DEP_OTHER>
      <ADMIN_DEP_2_DEP>Dept 2</ADMIN_DEP_2_DEP>
      <ADMIN_DEP_2_DEP_OTHER>Other 2</ADMIN_DEP_2_DEP_OTHER>
      <ADMIN_DEP_3_DEP>Dept 3</ADMIN_DEP_3_DEP>
      <ADMIN_DEP_3_DEP_OTHER>Other 3</ADMIN_DEP_3_DEP_OTHER>
      <TITLE>Associate</TITLE>
      <RANK>Professor</RANK>
      <TENURE>Tenured</TENURE>
      <ENDPOS>Associate Professor</ENDPOS>
      <GRADUATE>Yes</GRADUATE>
      <TIME_STATUS>Full-Time</TIME_STATUS>
      <HR_CODE>ACT</HR_CODE>
    </ADMIN>
  </Record>
  <Record username=\"#{faculty2.access_id}\">
    <ADMIN>
      <AC_YEAR>2023-2024</AC_YEAR>
      <CAMPUS>UP</CAMPUS>
      <CAMPUS_NAME>University Park</CAMPUS_NAME>
      <COLLEGE>EN</COLLEGE>
      <COLLEGE_NAME>College of Engineering</COLLEGE_NAME>
      <SCHOOL>Other School</SCHOOL>
      <DIVISION>Other Division</DIVISION>
      <INSTITUTE>Institute</INSTITUTE>
      <ADMIN_DEP_1_DEP>Dept 1</ADMIN_DEP_1_DEP>
      <ADMIN_DEP_1_DEP_OTHER>Other 1</ADMIN_DEP_1_DEP_OTHER>
      <ADMIN_DEP_2_DEP>Dept 2</ADMIN_DEP_2_DEP>
      <ADMIN_DEP_2_DEP_OTHER>Other 2</ADMIN_DEP_2_DEP_OTHER>
      <ADMIN_DEP_3_DEP>Dept 3</ADMIN_DEP_3_DEP>
      <ADMIN_DEP_3_DEP_OTHER>Other 3</ADMIN_DEP_3_DEP_OTHER>
      <TITLE>Associate</TITLE>
      <RANK>Professor</RANK>
      <TENURE>Tenured</TENURE>
      <ENDPOS>Associate Professor</ENDPOS>
      <GRADUATE>Yes</GRADUATE>
      <TIME_STATUS>Full-Time</TIME_STATUS>
      <HR_CODE>ACT</HR_CODE>
    </ADMIN>
  </Record>
</Data>
")
    end
  end
end