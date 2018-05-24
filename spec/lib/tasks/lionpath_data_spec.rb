require 'rails_helper'

  RSpec.describe 'lionpath_data' do

    headers = ['Instructor Campus ID', 'Term', 'Calendar Year', 'Class Campus Code', 'Course Short Description', 'Course Long Description',
               'Academic Course ID', 'Cross Listed Flag', 'Subject Code', 'Class Section Code', 'Course Credits/Units',
               'Current Enrollment', 'Instructor Load Factor', 'Instruction Mode', 'Course Component', 'Course Number',
               'Course Suffix', 'XCourse CoursePre', 'XCourse CourseNum', 'XCourse CourseNum Suffix', 'm_name', 'l_name', 'f_name']

    let(:fake_sheet) do
      data_arr = []
      arr_of_hashes = []
      keys = headers
      data_arr << ['abc123', 'Spring', 2018, 'UP', 'Computer Stuff', 'Fun things that you can do with a computer that are fun.',
                   9999, 'N', 'CMPSC', 001, 3, 25, 100, 'Hybrid - Online & In Person', 'Lecture', 200, '', '', '', 'Billy', 'Club', 'Arnold']
      data_arr << ['def456', 'Spring', 2018, 'UP', 'Computer Stuff', 'Fun things that you can do with a computer that are fun.',
                   9999, 'N', 'CMPSC', 002, 3, 20, 100, 'In Person', 'Lecture', 200, '', '', '', 'Ernest', 'Frankenstein', 'Delaney']
      data_arr << ['abc123', 'Spring', 2018, 'UP', 'Fruit Science', 'The science of fruits and why they are food.',
                   1111, 'N', 'FDSC', 001, 3, 30, 100, 'In Person', 'Lecture', 100, '', '', '', 'Billy', 'Club', 'Arnold']
      data_arr << ['ghi789', 'Spring', 2018, 'UP', 'Bioinformatics', 'High Throughput Sequencing of Globulandus microRNAs.',
                   2222, 'N', 'BIOTC', 001, 3, 12, 100, 'In Person', 'Lecture', 110, '', '', '', 'Harold', 'Ibanez', 'Glob']
      data_arr.each {|a| arr_of_hashes << Hash[ keys.zip(a) ] }
      arr_of_hashes
    end

    describe 'populate database' do
      it 'should populate the database with lionpath data' do
        fake_sheet.each do |row|
	  begin
            course = Course.create(term:                     row['Term'],
                                   calendar_year:            row['Calendar Year'],
                                   course_short_description: row['Course Short Description'],
                                   course_long_description:  row['Course Long Description'],
                                   academic_course_id:       row['Academic Course ID'])

          rescue ActiveRecord::RecordNotUnique
            course = Course.find_by(academic_course_id: row['Academic Course ID'])
          end

          begin
            faculty = Faculty.create(access_id: row['Instructor Campus ID'].downcase,
                                     f_name:    row['f_name'],
                                     l_name:    row['l_name'],
                                     m_name:    row['m_name'])

          rescue ActiveRecord::RecordNotUnique
            faculty = Faculty.find_by(access_id: row['Instructor Campus ID'].downcase)
          end

          Section.create(course:                 course,
                         faculty:                faculty,
                         class_campus_code:      row['Class Campus Code'],
                         cross_listed_flag:      row['Cross Listed Flag'],
                         subject_code:           row['Subject Code'],
                         course_number:          row['Course Number'],
                         course_suffix:          row['Course Suffix'],
                         class_section_code:     row['Class Section Code'],
                         course_credits:         row['Course Credits/Units'],
                         current_enrollment:     row['Current Enrollment'],
                         instructor_load_factor: row['Instructor Load Factor'],
                         instruction_mode:       row['Instruction Mode'],
                         course_component:       row['Course Component'],
                         xcourse_course_pre:     row['XCourse CoursePre'],
                         xcourse_course_num:     row['XCourse CourseNum'],
                         xcourse_course_suf:     row['XCourse CourseNum Suffix'])
        end
        expect(Course.all.count).to eq(3)
        expect(Faculty.all.count).to eq(3)
        expect(Section.all.count).to eq(4)
        expect(Faculty.find_by(:access_id => 'abc123').sections.all.count).to eq(2)
        expect(Faculty.find_by(:access_id => 'ghi789').sections.first.course.academic_course_id).to eq(2222)
      end
    end
  end

