require 'rails_helper'
require 'spreadsheet'
require 'lionpath_format'

RSpec.describe LionPathFormat do

  let(:headers) {['Instructor Campus ID', 'Term', 'Calendar Year', 'Class Campus Code', 'Course Short Description', 'Course Long Description',
                  'Academic Course ID', 'Cross Listed Flag', 'Subject Code', 'Catalog Number', 'Class Section Code', 'Course Credits/Units',
                  'Current Enrollment', 'Instructor Load Factor', 'Instruction Mode', 'Course Component']}

  let(:line1) {['1-Mar-1983', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.', 
                9999, 'Y', 'MATH', 1, '01C', 3, 25, 100, 'In Person', 'Lecture']}

  let(:line2) {['1-Mar-6783', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.', 
                9999, 'Y', 'MATH', '77A', 1, 3, 25, 100, 'In Person', 'Lecture']}

  let(:line3) {['xxx111', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.', 
                1111, 'N', 'MATH', '202D', '901', 3, 25, 100, 'In Person', 'Lecture']}

  let(:line4) {['23-Jan-2018', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.', 
                1111, 'N', 'MATH', 20, 1, 3, 25, 100, 'In Person', 'Lecture']}

  let(:line5) {['zzz999', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.', 
                1111, 'N', 'MATH', 20, 1, 3, 25, 100, 'In Person', 'Lecture']}

  let(:line6) {['1-Mar-1983', 'Spring 2018', 2018, 'UP', 'Math', 'Lots of math.', 
                9999, 'Y', 'MATH', '77A', 1, 3, 25, 100, 'In Person', 'Online']}

  let(:book) do
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    sheet.row(1).replace []
    sheet.row(2).replace []
    sheet.row(3).replace ['Last Name', 'First Name', 'Middle Name', 'Email', 'Username', 'PSU ID #', 'Enabled?', 'Has Access to Manage Activities?',
			  'Campus', 'Campus Name', 'College', 'College Name', 'Department', 'Division', 'Institute', 'School', 'Security']
    sheet.row(4).replace ['X', 'Bill', 'X', 'X', 'zzz999', 'X', 'Yes', 'Yes', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']
    sheet.row(5).replace ['X', 'Jimmy', 'X', 'X', 'xxx111', 'X', 'No', 'No', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X']
    book
  end

  let(:lionpath_obj) {LionPathFormat.new([headers, line1, line2, line3, line4, line5, line6], book)}

  describe '#format' do
    it 'should convert dates back into psuIDs and
        should convert "Term" to just season and
        should seperate "Catalog Number" into "Course Number" and "Course Suffix" and
        should add leading zeroes to "Course Number" column and
        should add leading zeroes to "Class Section Code" column and
        should seperate "Course Suffix" from "Class Section Code" and
        should add data to "XCourse CoursePre" "XCourse CourseNum" "XCourse CourseNum Suffix"' do
      lionpath_obj.format
      expect(lionpath_obj.csv_hash[0]['Instructor Campus ID']).to eq('mar83')
      expect(lionpath_obj.csv_hash[1]['Instructor Campus ID']).to eq('mar6783')
      expect(lionpath_obj.csv_hash[2]['Instructor Campus ID']).to eq('xxx111')
      expect(lionpath_obj.csv_hash[3]['Instructor Campus ID']).to eq('jan23')
      expect(lionpath_obj.csv_hash[0]['Term']).to eq('Spring')
      expect(lionpath_obj.csv_hash[0]['Course Number']).to eq('001')
      expect(lionpath_obj.csv_hash[1]['Course Number']).to eq('077')
      expect(lionpath_obj.csv_hash[2]['Course Number']).to eq('202')
      expect(lionpath_obj.csv_hash[3]['Course Number']).to eq('020')
      expect(lionpath_obj.csv_hash[1]['Course Suffix']).to eq('A')
      expect(lionpath_obj.csv_hash[0].length).to eq(20)
      expect(lionpath_obj.csv_hash[0]['Class Section Code']).to eq('001')
      expect(lionpath_obj.csv_hash[0]['Course Suffix']).to eq('C')
      expect(lionpath_obj.csv_hash[1]['Class Section Code']).to eq('001')
      expect(lionpath_obj.csv_hash[2]['Class Section Code']).to eq('901')
      expect(lionpath_obj.csv_hash[0]['XCourse CoursePre']).to eq('MATH')
      expect(lionpath_obj.csv_hash[0]['XCourse CourseNum']).to eq('077')
      expect(lionpath_obj.csv_hash[0]['XCourse CourseNum Suffix']).to eq('A')
      expect(lionpath_obj.csv_hash[5]['XCourse CoursePre']).to eq('MATH')
      expect(lionpath_obj.csv_hash[5]['XCourse CourseNum']).to eq('001')
      expect(lionpath_obj.csv_hash[5]['XCourse CourseNum Suffix']).to eq('C')
    end
  end

  describe '#filter_by_user' do
    it 'should filter lionpath data by AI user' do
      lionpath_obj.format
      lionpath_obj.filter_by_user
      expect(lionpath_obj.csv_hash.count).to eq(1)
      expect(lionpath_obj.csv_hash[0]['Instructor Campus ID']).to eq('zzz999')
    end
  end
end
