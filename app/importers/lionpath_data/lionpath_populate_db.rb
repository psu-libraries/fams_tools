require 'lionpath_data/lionpath_parser'

class LionpathData::LionpathPopulateDb
  attr_accessor :lionpath_parser

  def initialize(lionpath_parser_obj = LionpathData::LionpathParser.new)
    @lionpath_parser = lionpath_parser_obj
  end

  def format_and_filter
    lionpath_parser.format
    lionpath_parser.filter_by_user
    lionpath_parser.filter_campus
    lionpath_parser.remove_duplicates
  end

  def populate
    lionpath_parser.csv_hash.each do |row|
      begin
        course = Course.create(term: row['Term'],
                               calendar_year: row['Calendar Year'],
                               course_short_description: row['Course Short Description'].gsub(/[\u0001-\u001A]/, ''),
                               course_long_description: row['Course Long Description'].gsub(/[\u0001-\u001A]/, ''),
                               academic_course_id: row['Academic Course ID'])
      rescue ActiveRecord::RecordNotUnique
        course = Course.find_by(academic_course_id: row['Academic Course ID'],
                                term: row['Term'],
                                calendar_year: row['Calendar Year'])
      end

      faculty = Faculty.find_by(access_id: row['Instructor Campus ID'].downcase)

      begin
        Section.create(course:,
                       faculty:,
                       class_campus_code: row['Class Campus Code'],
                       cross_listed_flag: row['Cross Listed Flag'],
                       subject_code: row['Subject Code'],
                       course_number: row['Course Number'],
                       course_suffix: row['Course Suffix'],
                       class_section_code: row['Class Section Code'],
                       course_credits: row['Course Credits/Units'],
                       current_enrollment: row['Current Enrollment'],
                       instructor_load_factor: row['Instructor Load Factor'],
                       instruction_mode: row['Instructor Mode'],
                       instructor_role: row['Instructor Role'],
                       course_component: row['Course Component'],
                       xcourse_course_pre: row['XCourse CoursePre'],
                       xcourse_course_num: row['XCourse CourseNum'],
                       xcourse_course_suf: row['XCourse CourseNum Suffix'])
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end
end
