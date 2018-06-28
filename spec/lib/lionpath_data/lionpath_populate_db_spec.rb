require 'rails_helper'
require 'lionpath_data/lionpath_populate_db'

RSpec.describe LionPathPopulateDB do

  headers = ['Instructor Campus ID', 'Term', 'Calendar Year', 'Class Campus Code', 'Course Short Description', 'Course Long Description',
             'Academic Course ID', 'Cross Listed Flag', 'Subject Code', 'Class Section Code', 'Course Credits/Units',
             'Current Enrollment', 'Instructor Load Factor', 'Instruction Mode', 'Course Component', 'Course Number',
             'Course Suffix', 'XCourse CoursePre', 'XCourse CourseNum', 'XCourse CourseNum Suffix', 'm_name', 'l_name', 'f_name']

  let(:fake_sheet) do
    data_arr = []
    arr_of_hashes = []
    keys = headers
    data_arr << ['abc123', 'Spring', 2018, 'UP', 'Computer Stuff', 'Fun things that you can do with a computer that are fun.',
                 9999, 'N', 'CMPSC', 001, 3, 25, 100, 'Hybrid - Online & In Person', 'Lecture', 200, '', '', '']
    data_arr << ['def456', 'Spring', 2018, 'UP', 'Computer Stuff', 'Fun things that you can do with a computer that are fun.',
                 9999, 'N', 'CMPSC', 002, 3, 20, 100, 'In Person', 'Lecture', 200, '', '', '']
    data_arr << ['abc123', 'Spring', 2018, 'UP', 'Fruit Science', 'The science of fruits and why they are food.',
                 1111, 'N', 'FDSC', 001, 3, 30, 100, 'In Person', 'Lecture', 100, '', '', '']
    data_arr << ['ghi789', 'Spring', 2018, 'UP', 'Bioinformatics', 'High Throughput Sequencing of Globulandus microRNAs.',
                 2222, 'N', 'BIOTC', 001, 3, 12, 100, 'In Person', 'Lecture', 110, '', '', '']
    data_arr.each {|a| arr_of_hashes << Hash[ keys.zip(a) ] }
    arr_of_hashes
  end

  let(:lionpath_populate_db_obj) {LionPathPopulateDB.allocate}

  before(:each) do
    Faculty.create(access_id: 'abc123',
                   user_id:   '123456',
                   f_name:    'Bill',
                   l_name:    'Bill',
                   m_name:    'Bill')
    Faculty.create(access_id: 'def456',
                   user_id:   '54321',
                   f_name:    'Will',
                   l_name:    'Will',
                   m_name:    'Will')
    Faculty.create(access_id: 'ghi789',
                   user_id:   '578343',
                   f_name:    'Frank',
                   l_name:    'Frank',
                   m_name:    'Frank')
  end

  describe '#populate' do
    it 'should populate the database with lionpath data' do
      lionpath_populate_db_obj.lionpath_parser = LionPathParser.allocate
      lionpath_populate_db_obj.lionpath_parser.csv_hash = fake_sheet
      lionpath_populate_db_obj.populate
      expect(Course.all.count).to eq(3)
      expect(Faculty.all.count).to eq(3)
      expect(Section.all.count).to eq(4)
      expect(Faculty.find_by(:access_id => 'abc123').sections.all.count).to eq(2)
      expect(Faculty.find_by(:access_id => 'ghi789').sections.first.course.academic_course_id).to eq(2222)
    end
  end

end
