require 'importers/importers_helper'

RSpec.describe ComData::ComEffortXmlBuilder do
  let(:data_sets) do
    [{ 'FACULTY_USERNAME' => 'lskywalker',
       'FACULTY_NAME' => 'Skywalker Luke',
       'COURSE' => 'the Force',
       'COURSE_YEAR' => '1976-1977',
       'EVENT_TYPE' => 'Lecture',
       'EVENT' => 'FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid',
       'EVENT_DATE' => '5/25/77',
       'UME_CALCULATED_TEACHING_WHILE_NON_BILLING_EFFORT__HRS_' => 2 },
     { 'FACULTY_USERNAME' => 'hgranger',
       'FACULTY_NAME' => 'Granger Hermione',
       'COURSE' => 'Potions',
       'COURSE_YEAR' => '1997-1998',
       'EVENT_TYPE' => 'Sm Grp Facilitation',
       'EVENT' => 'FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid',
       'EVENT_DATE' => '6/26/97',
       'UME_CALCULATED_TEACHING_WHILE_NON_BILLING_EFFORT__HRS_' => 7 },
     { 'FACULTY_USERNAME' => 'notCOM',
       'FACULTY_NAME' => 'Not MD',
       'COURSE' => 'test',
       'COURSE_YEAR' => '2022-2023',
       'EVENT_TYPE' => 'Lacture',
       'EVENT' => 'Test Event for employee not in College of Medicine',
       'EVENT_DATE' => '1/1/23',
       'UME_CALCULATED_TEACHING_WHILE_NON_BILLING_EFFORT__HRS_' => 1 }]
  end

  let(:xml_builder_obj) { ComData::ComEffortXmlBuilder.new }

  describe '#build_xml_effort' do
    it 'should return a list with an xml of INSTRUCT_TAUGHT records' do
      data_sets.each do |row|
        faculty = if row['FACULTY_USERNAME'] == 'notCOM'
                    FactoryBot.create :faculty, com_id: row['FACULTY_USERNAME'], college: 'IST'
                  else
                    FactoryBot.create :faculty, com_id: row['FACULTY_USERNAME'], college: 'MD'
                  end

        ComEffort.create(com_id: row['FACULTY_USERNAME'],
                         course_year: row['COURSE_YEAR'],
                         course: row['COURSE'],
                         event_type: row['EVENT_TYPE'],
                         faculty_name: row['FACULTY_NAME'],
                         event: row['EVENT'],
                         event_date: row['EVENT_DATE'],
                         hours: row['UME_CALCULATED_TEACHING_WHILE_NON_BILLING_EFFORT__HRS_'],
                         faculty:)
      end
      expect(xml_builder_obj.xmls_enumerator_effort.first).to eq(
        '<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record PennStateHealthUsername="lskywalker">
    <INSTRUCT_TAUGHT>
      <COURSE_YEAR access="READ_ONLY">1976-1977</COURSE_YEAR>
      <COURSE_TITLE access="READ_ONLY">the Force</COURSE_TITLE>
      <EVENT_TITLE access="READ_ONLY">FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid</EVENT_TITLE>
      <EVENT_TYPE access="READ_ONLY">Lecture</EVENT_TYPE>
      <DTM_EVENT access="READ_ONLY">May</DTM_EVENT>
      <DTD_EVENT access="READ_ONLY">25</DTD_EVENT>
      <DTY_EVENT access="READ_ONLY">1977</DTY_EVENT>
      <CAL_TEACH_HRS access="READ_ONLY">2</CAL_TEACH_HRS>
    </INSTRUCT_TAUGHT>
  </Record>
  <Record PennStateHealthUsername="hgranger">
    <INSTRUCT_TAUGHT>
      <COURSE_YEAR access="READ_ONLY">1997-1998</COURSE_YEAR>
      <COURSE_TITLE access="READ_ONLY">Potions</COURSE_TITLE>
      <EVENT_TITLE access="READ_ONLY">FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid</EVENT_TITLE>
      <EVENT_TYPE access="READ_ONLY">Sm Grp Facilitation</EVENT_TYPE>
      <DTM_EVENT access="READ_ONLY">June</DTM_EVENT>
      <DTD_EVENT access="READ_ONLY">26</DTD_EVENT>
      <DTY_EVENT access="READ_ONLY">1997</DTY_EVENT>
      <CAL_TEACH_HRS access="READ_ONLY">7</CAL_TEACH_HRS>
    </INSTRUCT_TAUGHT>
  </Record>
</Data>
'
      )
    end
  end
end
