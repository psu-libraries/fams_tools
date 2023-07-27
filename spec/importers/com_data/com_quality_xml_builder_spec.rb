require 'importers/importers_helper'

RSpec.describe ComData::ComQualityXmlBuilder do

  let(:data_sets) do
    [{'FACULTY_USERNAME' => 'batman',
      'FACULTY_NAME' => 'Wayne  Bruce',
      'COURSE' => 'Endocrinology/Reproductive',
      'COURSE_YEAR' => '1938-1939',
      'EVALUATION_TYPE' => 'faculty',
      'UME_AVERAGE_RATING' => 4.2,
      'NUMBER_OF_EVALUATIONS' => 1939,
      'EVALUATION_NAME' => 'Lecture'},
      {'FACULTY_USERNAME' => 'spiderman',
      'FACULTY_NAME' => 'Parker Peter',
      'COURSE' => 'Swinging',
      'COURSE_YEAR' => '1962-1963',
      'EVALUATION_TYPE' => 'faculty',
      'UME_AVERAGE_RATING' => 5.0,
      'NUMBER_OF_EVALUATIONS' => 575,
      'EVALUATION_NAME' => 'Sm Grp Facilitation'}
    ]
  end

  let(:xml_builder_obj) {ComData::ComQualityXmlBuilder.new}

  describe '#build_xml_quality' do
    it 'should return a list with an xml of COURSE_EVAL records' do
      data_sets.each do |row|
        faculty = FactoryBot.create :faculty, com_id: row['FACULTY_USERNAME'], college: 'MD'
        begin
          ComQuality.create(com_id:           row['FACULTY_USERNAME'],
                            course_year:      row['COURSE_YEAR'],
                            course:           row['COURSE'],
                            event_type:       row['EVALUATION_NAME'],
                            faculty_name:     row['FACULTY_NAME'],
                            evaluation_type:  row['EVALUATION_TYPE'],
                            average_rating:   row['UME_AVERAGE_RATING'],
                            num_evaluations:  row['NUMBER_OF_EVALUATIONS'],
                            faculty:          faculty)
          rescue ActiveRecord::RecordNotUnique
        end
      end
      expect(xml_builder_obj.xmls_enumerator_quality.first).to eq(
'<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record PennStateHealthUsername="batman">
    <COURSE_EVAL>
      <COURSE_YEAR access="READ_ONLY">1938-1939</COURSE_YEAR>
      <COURSE_NAME access="READ_ONLY">Endocrinology/Reproductive</COURSE_NAME>
      <EVAL_NAME access="READ_ONLY">Lecture</EVAL_NAME>
      <RATING_AVG access="READ_ONLY">4.2</RATING_AVG>
      <NUM_EVAL access="READ_ONLY">1939</NUM_EVAL>
    </COURSE_EVAL>
  </Record>
  <Record PennStateHealthUsername="spiderman">
    <COURSE_EVAL>
      <COURSE_YEAR access="READ_ONLY">1962-1963</COURSE_YEAR>
      <COURSE_NAME access="READ_ONLY">Swinging</COURSE_NAME>
      <EVAL_NAME access="READ_ONLY">Sm Grp Facilitation</EVAL_NAME>
      <RATING_AVG access="READ_ONLY">5.0</RATING_AVG>
      <NUM_EVAL access="READ_ONLY">575</NUM_EVAL>
    </COURSE_EVAL>
  </Record>
</Data>
'
      )

      end
    end
end
