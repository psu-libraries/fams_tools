require 'importers/importers_helper'
require 'spreadsheet'

RSpec.describe LionPathParser do

  let(:headers) {['Instructor Campus ID', 'Term', 'Calendar Year', 'Class Campus Code', 'Course Short Description', 'Course Long Description',
                  'Academic Course ID', 'Cross Listed Flag', 'Subject Code', 'Catalog Number', 'Class Section Code', 'Course Credits/Units',
                  'Current Enrollment', 'Instructor Load Factor', 'Instructor Mode', 'Course Component', 'Instructor Role']}

  let(:line1) {['mar83', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.',
                9999, 'Y', 'MATH', 1, '01C', 3, 25, 100, 'Hybrid - Online & In Person', 'Lecture', 'Primary Instructor']}

  let(:line2) {['mar6783', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.',
                2222, 'Y', 'MATH', '77A', 1, 3, 25, 100, 'In Person', 'Lecture', 'Secondary Instructor']}

  let(:line3) {['xxx111', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.', 
                1111, 'N', 'MATH', '202D', '901D', 3, 25, 100, 'In Person', 'Lecture', 'Primary Instructor']}

  let(:line4) {['jan23', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.',
                1111, 'N', 'MATH', 20, 1, 3, 25, 100, 'In Person', 'Lecture', 'Secondary Instructor']}

  let(:line5) {['zzz999', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.', 
                1111, 'N', 'MATH', 20, 1, 3, 25, 100, 'In Person', 'Lecture', 'Primary Instructor']}

  let(:line6) {['mar83', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.',
                9999, 'Y', 'MATH', '77A', 1, 3, 25, 100, 'In Person', 'Online', 'Secondary Instructor']}

  let(:line7) {['xxx111', 'Summer 2018', 2018, 'UP', 'Math', 'Lots of math.',
                1111, 'N', 'MATH', '202D', '901D', 3, 25, 0, 'In Person', '', 'Primary Instructor']}

  let(:lionpath_parser_obj) {LionPathParser.new}

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
      lionpath_parser_obj.format
      lionpath_parser_obj.csv_hash[6].delete 'Instructor Mode'
      expect(lionpath_parser_obj.csv_hash[0]['Instructor Campus ID']).to eq('mar83')
      expect(lionpath_parser_obj.csv_hash[1]['Instructor Campus ID']).to eq('mar6783')
      expect(lionpath_parser_obj.csv_hash[2]['Instructor Campus ID']).to eq('xxx111')
      expect(lionpath_parser_obj.csv_hash[3]['Instructor Campus ID']).to eq('jan23')
      expect(lionpath_parser_obj.csv_hash[0]['Term']).to eq('Spring')
      expect(lionpath_parser_obj.csv_hash[6]['Term']).to eq('Summer 1')
      expect(lionpath_parser_obj.csv_hash[0]['Course Number']).to eq('001')
      expect(lionpath_parser_obj.csv_hash[1]['Course Number']).to eq('077')
      expect(lionpath_parser_obj.csv_hash[2]['Course Number']).to eq('202')
      expect(lionpath_parser_obj.csv_hash[3]['Course Number']).to eq('020')
      expect(lionpath_parser_obj.csv_hash[1]['Course Suffix']).to eq('A')
      expect(lionpath_parser_obj.csv_hash[0].length).to eq(21)
      expect(lionpath_parser_obj.csv_hash[0]['Class Section Code']).to eq('001C')
      expect(lionpath_parser_obj.csv_hash[0]['Course Suffix']).to eq(nil)
      expect(lionpath_parser_obj.csv_hash[1]['Class Section Code']).to eq('001')
      expect(lionpath_parser_obj.csv_hash[2]['Class Section Code']).to eq('901D')
      expect(lionpath_parser_obj.csv_hash[0]['XCourse CoursePre']).to eq('MATH')
      expect(lionpath_parser_obj.csv_hash[0]['XCourse CourseNum']).to eq('077')
      expect(lionpath_parser_obj.csv_hash[0]['XCourse CourseNum Suffix']).to eq('A')
      expect(lionpath_parser_obj.csv_hash[5]['XCourse CoursePre']).to eq('MATH')
      expect(lionpath_parser_obj.csv_hash[5]['XCourse CourseNum']).to eq('001')
      expect(lionpath_parser_obj.csv_hash[5]['XCourse CourseNum Suffix']).to eq(nil)
      expect(lionpath_parser_obj.csv_hash[0]['Instructor Mode']).to eq('Hybrid - Online & In Person')
      expect(lionpath_parser_obj.csv_hash[0]['Instructor Role']).to eq('Primary Instructor')
      expect(lionpath_parser_obj.csv_hash[6].keys).not_to include('Instructor Mode')
    end
  end

  describe '#filter_by_user' do
    it 'should filter lionpath data by AI user' do
      allow(CSV).to receive_message_chain(:read).and_return([headers, line1, line2, line3, line4, line5, line6, line7])
      lionpath_parser_obj.format
      lionpath_parser_obj.filter_by_user
      expect(lionpath_parser_obj.csv_hash.count).to eq(1)
      expect(lionpath_parser_obj.csv_hash[0]['Instructor Campus ID']).to eq('zzz999')
    end
  end

  describe '#remove_duplicates' do
    it 'should remove records that are the same except for instructor_load_factor' do
      allow(CSV).to receive_message_chain(:read).and_return([headers, line1, line2, line3, line4, line5, line6, line7])
      lionpath_parser_obj.format
      lionpath_parser_obj.remove_duplicates
      expect(lionpath_parser_obj.csv_hash.count).to eq(7)
    end
  end
end
