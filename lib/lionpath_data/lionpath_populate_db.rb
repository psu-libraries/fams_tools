require 'lionpath_data/lionpath_parser'

class LionPathPopulateDB
  attr_accessor :lionpath_parser

  def initialize
    @lionpath_parser = LionPathParser.new
  end

  def format_and_filter
    lionpath_parser.format
    lionpath_parser.filter_by_user
    lionpath_parser.remove_duplicates
  end

  def write
    lionpath_parser.write_results_to_xl
    lionpath_parser.write_flagged_to_xl
  end
  
  def populate
    lionpath_parser.csv_hash.each do |row|
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
                                 user_id:   row['userid'],
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
  end

end
