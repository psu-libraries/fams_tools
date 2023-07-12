require 'importers/importers_helper'
require 'spreadsheet'

RSpec.describe ComData::ComParser do
  # effort
  let(:headers_e) {['FACULTY_USERNAME', 'FACULTY_NAME', 'COURSE', 'COURSE_YEAR', 'EVENT_TYPE', 'EVENT',
                  'EVENT_DATE', 'UME_CALCULATED_TEACHING_WHILE_NON_BILLING_EFFORT__HRS_']}

  let(:line1_e) {['lskywalker', 'Skywalker Luke', 'Endocrinology/Reproductive',  '2022-2023', 'Sm Grp Facilitation',
                  'FTF REQ Various Rooms 10-12 PBL - EndoRepro PBL 1402 - Thyroid', '5/25/77 10:00', 2]}

  # quality
  let(:headers_q) {['FACULTY_USERNAME', 'FACULTY_NAME', 'COURSE', 'COURSE_YEAR', 'EVALUATION_TYPE', 'UME_AVERAGE_RATING',
                  'NUMBER_OF_EVALUATIONS', 'EVALUATION_NAME']}

  let(:line1_q) {['batman', 'Wayne  Bruce', 'Endocrinology/Reproductive',  '1938-1939', 'faculty', 4.2, 1939, 'Lecture']}

  let(:line2_q) {['spiderman', 'Parker  Peter', 'Endocrinology/Reproductive',  '1962-1963', 'faculty', 5.0, 575, 'Lecture']}

  let(:com_parser_obj) {ComData::ComParser.new}

  before(:each) do
    Faculty.create(access_id: 'zzz999',
                   user_id:   '123',
                   f_name:    'Bill',
                   l_name:    'Bill',
                   m_name:    'Bill')
  end

  describe '#format' do
    it 'should convert dates back into psuIDs and
        should convert "Term" to just season and
        should seperate "Catalog Number" into "Course Number" and "Course Suffix" and
        should add leading zeroes to "Course Number" column and
        should add leading zeroes to "Class Section Code" column and
        should seperate "Course Suffix" from "Class Section Code" and
        should add data to "XCourse CoursePre" "XCourse CourseNum" "XCourse CourseNum Suffix"' do
      allow(CSV).to receive_message_chain(:read).and_return([headers, line1, line2, line3, line4, line5, line6, line7])
      com_parser_obj.format
      com_parser_obj.csv_hash[6].delete 'Instructor Mode'
      expect(com_parser_obj.csv_hash[0]['Instructor Campus ID']).to eq('mar83')
      expect(com_parser_obj.csv_hash[1]['Instructor Campus ID']).to eq('mar6783')
      expect(com_parser_obj.csv_hash[2]['Instructor Campus ID']).to eq('xxx111')
      expect(com_parser_obj.csv_hash[3]['Instructor Campus ID']).to eq('jan23')
      expect(com_parser_obj.csv_hash[0]['Term']).to eq('Spring')
      expect(com_parser_obj.csv_hash[6]['Term']).to eq('Summer 1')
      expect(com_parser_obj.csv_hash[0]['Course Number']).to eq('001')
      expect(com_parser_obj.csv_hash[1]['Course Number']).to eq('077')
      expect(com_parser_obj.csv_hash[2]['Course Number']).to eq('202')
      expect(com_parser_obj.csv_hash[3]['Course Number']).to eq('020')
      expect(com_parser_obj.csv_hash[1]['Course Suffix']).to eq('A')
      expect(com_parser_obj.csv_hash[0].length).to eq(21)
      expect(com_parser_obj.csv_hash[0]['Class Section Code']).to eq('001C')
      expect(com_parser_obj.csv_hash[0]['Course Suffix']).to eq(nil)
      expect(com_parser_obj.csv_hash[1]['Class Section Code']).to eq('001')
      expect(com_parser_obj.csv_hash[2]['Class Section Code']).to eq('901D')
      expect(com_parser_obj.csv_hash[0]['XCourse CoursePre']).to eq('MATH')
      expect(com_parser_obj.csv_hash[0]['XCourse CourseNum']).to eq('077')
      expect(com_parser_obj.csv_hash[0]['XCourse CourseNum Suffix']).to eq('A')
      expect(com_parser_obj.csv_hash[5]['XCourse CoursePre']).to eq('MATH')
      expect(com_parser_obj.csv_hash[5]['XCourse CourseNum']).to eq('001')
      expect(com_parser_obj.csv_hash[5]['XCourse CourseNum Suffix']).to eq(nil)
      expect(com_parser_obj.csv_hash[0]['Instructor Mode']).to eq('Hybrid - Online & In Person')
      expect(com_parser_obj.csv_hash[0]['Instructor Role']).to eq('Primary Instructor')
      expect(com_parser_obj.csv_hash[6].keys).not_to include('Instructor Mode')
    end
  end

  describe '#filter_by_user' do
    it 'should filter com data by AI user' do
      allow(CSV).to receive_message_chain(:read).and_return([headers, line1, line2, line3, line4, line5, line6, line7])
      com_parser_obj.format
      com_parser_obj.filter_by_user
      expect(com_parser_obj.csv_hash.count).to eq(1)
      expect(com_parser_obj.csv_hash[0]['Instructor Campus ID']).to eq('zzz999')
    end
  end

  describe '#remove_duplicates' do
    it 'should remove records that are the same except for instructor_load_factor' do
      allow(CSV).to receive_message_chain(:read).and_return([headers, line1, line2, line3, line4, line5, line6, line7])
      com_parser_obj.format
      com_parser_obj.remove_duplicates
      expect(com_parser_obj.csv_hash.count).to eq(7)
    end
  end
end
