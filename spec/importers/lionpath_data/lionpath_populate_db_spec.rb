require 'importers/importers_helper'

RSpec.describe LionpathData::LionpathPopulateDb do
  headers = ['Instructor Campus ID', 'Term', 'Calendar Year', 'Class Campus Code', 'Course Short Description', 'Course Long Description',
             'Academic Course ID', 'Cross Listed Flag', 'Subject Code', 'Class Section Code', 'Course Credits/Units',
             'Current Enrollment', 'Instructor Load Factor', 'Instructor Mode', 'Course Component', 'Instructor Role', 'Course Number',
             'Course Suffix', 'XCourse CoursePre', 'XCourse CourseNum', 'XCourse CourseNum Suffix', 'm_name', 'l_name', 'f_name']

  let(:fake_sheet) do
    data_arr = []
    keys = headers
    data_arr << ['abc123', 'Spring', 2018, 'UP', 'Computer Stuff', 'Fun things that you can do with a computer that are fun.',
                 9999, 'N', 'CMPSC', 0o01, 3, 25, 100, 'Hybrid - Online & In Person', 'Lecture', 'Primary Instructor', 200, '', '', '']
    data_arr << ['def456', 'Spring', 2018, 'UP', 'Computer Stuff', 'Fun things that you can do with a computer that are fun.',
                 9999, 'N', 'CMPSC', 0o02, 3, 20, 100, 'In Person', 'Lecture', 'Primary Instructor', 200, '', '', '']
    data_arr << ['abc123', 'Spring', 2018, 'UP', 'Fruit Science', 'The science of fruits and why they are food.',
                 1111, 'N', 'FDSC', 0o01, 3, 30, 100, 'In Person', 'Lecture', 'Primary Instructor', 100, '', '', '']
    data_arr << ['ghi789', 'Spring', 2018, 'UP', 'Bioinformatics', 'High Throughput Sequencing of Globulandus microRNAs.',
                 2222, 'N', 'BIOTC', 0o01, 3, 12, 100, 'In Person', 'Lecture', 'Primary Instructor', 110, '', '', '']
    data_arr.map { |a| keys.zip(a).to_h }
  end

  let(:lionpath_populate_db_obj) { LionpathData::LionpathPopulateDb.allocate }

  before do
    Faculty.create(access_id: 'abc123',
                   user_id: '123456',
                   f_name: 'Bill',
                   l_name: 'Bill',
                   m_name: 'Bill')
    Faculty.create(access_id: 'def456',
                   user_id: '54321',
                   f_name: 'Will',
                   l_name: 'Will',
                   m_name: 'Will')
    Faculty.create(access_id: 'ghi789',
                   user_id: '578343',
                   f_name: 'Frank',
                   l_name: 'Frank',
                   m_name: 'Frank')
  end

  describe '#populate' do
    it 'populates the database with lionpath data' do
      lionpath_populate_db_obj.lionpath_parser = LionpathData::LionpathParser.allocate
      lionpath_populate_db_obj.lionpath_parser.csv_hash = fake_sheet
      lionpath_populate_db_obj.populate
      expect(Course.count).to eq(3)
      expect(Faculty.count).to eq(3)
      expect(Section.count).to eq(4)
      expect(Faculty.find_by(access_id: 'abc123').sections.count).to eq(2)
      expect(Faculty.find_by(access_id: 'ghi789').sections.first.course.academic_course_id).to eq(2222)
      expect(Faculty.find_by(access_id: 'ghi789').sections.first.instructor_role).to eq('Primary Instructor')
    end
  end
end
