require 'lionpath_format'

namespace :lionpath_data do

  desc "Filter and format LionPath data"

  task format: :environment do
    start = Time.now
    my_lionpath = LionPathFormat.new
    my_lionpath.format
    my_lionpath.filter_by_user
    my_lionpath.write_results_to_xl
    my_lionpath.write_flagged_to_xl
    my_lionpath.csv_hash.each do |row|
      begin
        course = Course.create(term: row['Term'],
                               calendar_year: row['Calendar Year'],
                               course_short_description: row['Course Short Description'],
                               course_long_description: row['Course Long Description'],
                               academic_course_id: row['Academic Course ID'])

      rescue ActiveRecord::RecordNotUnique
        course = Course.find_by(academic_course_id: row['Academic Course ID'])
      end

      faculty = Faculty.find_by(access_id: row['Instructor Campus ID'].downcase)

      Section.create(course: course,
                     faculty: faculty,
                     class_campus_code: row['Class Campus Code'],
                     cross_listed_flag: row['Cross Listed Flag'],
                     subject_code: row['Subject Code'],
                     course_number: row['Course Number'],
                     course_suffix: row['Course Suffix'],
                     class_section_code: row['Class Section Code'],
                     course_credits: row['Course Credits/Units'],
                     current_enrollment: row['Current Enrollment'],
                     instructor_load_factor: row['Instructor Load Factor'],
                     instruction_mode: row['Instruction Mode'],
                     course_component: row['Course Component'],
                     xcourse_course_pre: row['XCourse CoursePre'],
                     xcourse_course_num: row['XCourse CourseNum'],
                     xcourse_course_suf: row['XCourse CourseNum Suffix'])
    end
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end

end

