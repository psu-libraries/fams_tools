require 'importers/importers_helper'

RSpec.describe LionPathXMLBuilder do

  let(:data_sets) do
    [{'Term' => 'Spring', 'Calendar Year' => 2018, 'Course Short Description' => 'The Class', 'Course Long Description' => 'This is the class that a teacher teaches.',
      'Academic Course ID' => 12345, 'Instructor Campus ID' => 'abc123', 'f_name' => 'Allen', 'l_name' => 'Carter', 'm_name' => 'Bob',
      'Class Campus Code' => 'UP', 'Cross Listed Flag' => 'N', 'Subject Code' => 'MGMT', 'Course Number' => '001', 'Course Suffix' => 'B',
      'Class Section Code' => '001', 'Course Credits/Units' => 3, 'Current Enrollment' => 100, 'Instructor Mode' => 'In Person', 'Instructor Role' => 'Primary Instructor',
      'Course Component' => 'Lecture', 'XCourse CoursePre' => '', 'XCourse CourseNum' => '', 'XCourse CourseNum Suffix' => '', 'Instructor Load Factor' => 100},
     {'Term' => 'Spring', 'Calendar Year' => 2018, 'Course Short Description' => 'The Other Class', 'Course Long Description' => 'This is the class that students learn in.',
      'Academic Course ID' => 54321, 'Instructor Campus ID' => 'cba321', 'f_name' => 'Carl', 'l_name' => 'Abraham', 'm_name' => 'Brett',
      'Class Campus Code' => 'UP', 'Cross Listed Flag' => 'N', 'Subject Code' => 'HIST', 'Course Number' => '100', 'Course Suffix' => 'A',
      'Class Section Code' => '002', 'Course Credits/Units' => 3, 'Current Enrollment' => 50, 'Instructor Mode' => 'In Person', 'Instructor Role' => 'Primary Instructor',
      'Course Component' => 'Lecture', 'XCourse CoursePre' => '', 'XCourse CourseNum' => '', 'XCourse CourseNum Suffix' => '', 'Instructor Load Factor' => 100}]
  end

  let(:xml_builder_obj) {LionPathXMLBuilder.new}

  describe '#batched_lionpath_xml' do
    it 'should return a list with an xml of SCHTEACH records' do
      data_sets.each do |row|
        course = Course.create(term:                     row['Term'],
                               calendar_year:            row['Calendar Year'],
                               course_short_description: row['Course Short Description'],
                               course_long_description:  row['Course Long Description'],
                               academic_course_id:       row['Academic Course ID'])

        faculty = Faculty.create(access_id: row['Instructor Campus ID'].downcase,
                                 f_name:    row['f_name'],
                                 l_name:    row['l_name'],
                                 m_name:    row['m_name'],
                                 college: 'EN')

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
                       instruction_mode:       row['Instructor Mode'],
                       instructor_role:        row['Instructor Role'],
                       course_component:       row['Course Component'],
                       xcourse_course_pre:     row['XCourse CoursePre'],
                       xcourse_course_num:     row['XCourse CourseNum'],
                       xcourse_course_suf:     row['XCourse CourseNum Suffix'])
      end
      FactoryBot.create :section, course: (FactoryBot.create :course), faculty: (FactoryBot.create :faculty, college: 'EE')
      FactoryBot.create :section, course: (FactoryBot.create :course), faculty: (FactoryBot.create :faculty, college: 'SIA')
      expect(xml_builder_obj.xmls_enumerator.first).to eq(
'<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="abc123">
    <SCHTEACH>
      <TYT_TERM access="READ_ONLY">Spring</TYT_TERM>
      <TYY_TERM access="READ_ONLY">2018</TYY_TERM>
      <TITLE access="READ_ONLY">The Class</TITLE>
      <DESC access="READ_ONLY">This is the class that a teacher teaches.</DESC>
      <COURSEPRE access="READ_ONLY">MGMT</COURSEPRE>
      <COURSENUM access="READ_ONLY">001</COURSENUM>
      <COURSENUM_SUFFIX access="READ_ONLY">B</COURSENUM_SUFFIX>
      <SECTION access="READ_ONLY">001</SECTION>
      <CAMPUS access="READ_ONLY">UP</CAMPUS>
      <ENROLL access="READ_ONLY">100</ENROLL>
      <XCOURSE_COURSEPRE access="READ_ONLY"/>
      <XCOURSE_COURSENUM access="READ_ONLY"/>
      <XCOURSE_COURSENUM_SUFFIX access="READ_ONLY"/>
      <RESPON access="READ_ONLY">100</RESPON>
      <CHOURS access="READ_ONLY">3</CHOURS>
      <INST_MODE access="READ_ONLY">In Person</INST_MODE>
      <COURSE_COMP access="READ_ONLY">Lecture</COURSE_COMP>
      <ROLE access="READ_ONLY">Primary Instructor</ROLE>
    </SCHTEACH>
  </Record>
  <Record username="cba321">
    <SCHTEACH>
      <TYT_TERM access="READ_ONLY">Spring</TYT_TERM>
      <TYY_TERM access="READ_ONLY">2018</TYY_TERM>
      <TITLE access="READ_ONLY">The Other Class</TITLE>
      <DESC access="READ_ONLY">This is the class that students learn in.</DESC>
      <COURSEPRE access="READ_ONLY">HIST</COURSEPRE>
      <COURSENUM access="READ_ONLY">100</COURSENUM>
      <COURSENUM_SUFFIX access="READ_ONLY">A</COURSENUM_SUFFIX>
      <SECTION access="READ_ONLY">002</SECTION>
      <CAMPUS access="READ_ONLY">UP</CAMPUS>
      <ENROLL access="READ_ONLY">50</ENROLL>
      <XCOURSE_COURSEPRE access="READ_ONLY"/>
      <XCOURSE_COURSENUM access="READ_ONLY"/>
      <XCOURSE_COURSENUM_SUFFIX access="READ_ONLY"/>
      <RESPON access="READ_ONLY">100</RESPON>
      <CHOURS access="READ_ONLY">3</CHOURS>
      <INST_MODE access="READ_ONLY">In Person</INST_MODE>
      <COURSE_COMP access="READ_ONLY">Lecture</COURSE_COMP>
      <ROLE access="READ_ONLY">Primary Instructor</ROLE>
    </SCHTEACH>
  </Record>
</Data>
'
      )
        end
      end
    end
