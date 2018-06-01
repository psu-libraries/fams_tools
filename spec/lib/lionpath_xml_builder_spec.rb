require 'rails_helper'
require 'lionpath_xml_builder'

RSpec.describe LionPathXMLBuilder do

  let(:data_sets) do
    [{'Term' => 'Spring', 'Calendar Year' => 2018, 'Course Short Description' => 'The Class', 'Course Long Description' => 'This is the class that a teacher teaches.',
      'Acedemic Course ID' => 12345, 'Instructor Campus ID' => 'abc123', 'f_name' => 'Allen', 'l_name' => 'Carter', 'm_name' => 'Bob',
      'Class Campus Code' => 'UP', 'Cross Listed Flag' => 'N', 'Subject Code' => 'MGMT', 'Course Number' => 110, 'Course Suffix' => 'B',
      'Class Section Code' => '001', 'Course Credits/Units' => 3, 'Current Enrollment' => 100, 'Instruction Mode' => 'In Person',
      'Course Component' => 'Lecture', 'XCourse CoursePre' => '', 'XCourse CourseNum' => '', 'XCourse CourseNum Suffix' => '', 'Instructor Load Factor' => 100},
     {'Term' => 'Spring', 'Calendar Year' => 2018, 'Course Short Description' => 'The Other Class', 'Course Long Description' => 'This is the class that students learn in.',
      'Acedemic Course ID' => 54321, 'Instructor Campus ID' => 'cba321', 'f_name' => 'Carl', 'l_name' => 'Abraham', 'm_name' => 'Brett',
      'Class Campus Code' => 'UP', 'Cross Listed Flag' => 'N', 'Subject Code' => 'HIST', 'Course Number' => 100, 'Course Suffix' => 'A',
      'Class Section Code' => '002', 'Course Credits/Units' => 3, 'Current Enrollment' => 50, 'Instruction Mode' => 'In Person',
      'Course Component' => 'Lecture', 'XCourse CoursePre' => '', 'XCourse CourseNum' => '', 'XCourse CourseNum Suffix' => '', 'Instructor Load Factor' => 100}]
  end

  let(:lionpath_xml_builder_obj) {LionPathXMLBuilder.new}

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
                                 m_name:    row['m_name'])

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
      expect(lionpath_xml_builder_obj.batched_lionpath_xml).to eq([
'<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="abc123">
    <SCHTEACH>
      <TYT_TERM access="LOCKED">Spring</TYT_TERM>
      <TYY_TERM access="LOCKED">2018</TYY_TERM>
      <TITLE access="LOCKED">The Class</TITLE>
      <DESC access="LOCKED">This is the class that a teacher teaches.</DESC>
      <COURSEPRE access="LOCKED">MGMT</COURSEPRE>
      <COURSENUM access="LOCKED">110</COURSENUM>
      <COURSENUM_SUFFIX access="LOCKED">B</COURSENUM_SUFFIX>
      <SECTION access="LOCKED">001</SECTION>
      <CAMPUS access="LOCKED">UP</CAMPUS>
      <ENROLL access="LOCKED">100</ENROLL>
      <XCOURSE_COURSEPRE access="LOCKED"/>
      <XCOURSE_COURSENUM access="LOCKED"/>
      <XCOURSE_COURSENUM_SUFFIX access="LOCKED"/>
      <RESPON access="LOCKED">100</RESPON>
      <CHOURS access="LOCKED">3</CHOURS>
      <INST_MODE access="LOCKED">In Person</INST_MODE>
      <COURSE_COMP access="LOCKED">Lecture</COURSE_COMP>
    </SCHTEACH>
  </Record>
  <Record username="cba321">
    <SCHTEACH>
      <TYT_TERM access="LOCKED">Spring</TYT_TERM>
      <TYY_TERM access="LOCKED">2018</TYY_TERM>
      <TITLE access="LOCKED">The Other Class</TITLE>
      <DESC access="LOCKED">This is the class that students learn in.</DESC>
      <COURSEPRE access="LOCKED">HIST</COURSEPRE>
      <COURSENUM access="LOCKED">100</COURSENUM>
      <COURSENUM_SUFFIX access="LOCKED">A</COURSENUM_SUFFIX>
      <SECTION access="LOCKED">002</SECTION>
      <CAMPUS access="LOCKED">UP</CAMPUS>
      <ENROLL access="LOCKED">50</ENROLL>
      <XCOURSE_COURSEPRE access="LOCKED"/>
      <XCOURSE_COURSENUM access="LOCKED"/>
      <XCOURSE_COURSENUM_SUFFIX access="LOCKED"/>
      <RESPON access="LOCKED">100</RESPON>
      <CHOURS access="LOCKED">3</CHOURS>
      <INST_MODE access="LOCKED">In Person</INST_MODE>
      <COURSE_COMP access="LOCKED">Lecture</COURSE_COMP>
    </SCHTEACH>
  </Record>
</Data>
'
      ])
        end
      end
    end
