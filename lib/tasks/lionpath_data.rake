require 'lionpath_format'
require 'lionpath_xml_builder'

namespace :lionpath_data do

  desc "Filter and format LionPath data.
        Write to xls.
        Populate database."

  task format: :environment do
    start = Time.now
    my_lionpath = LionPathFormat.new
    my_lionpath.format
    my_lionpath.filter_by_user
    my_lionpath.remove_duplicates
    my_lionpath.write_results_to_xl
    my_lionpath.write_flagged_to_xl
    my_lionpath.csv_hash.each do |row|
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
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end

  desc "Integrate data into AI through WebServices."

  task integrate: :environment do
    start = Time.now
    my_lp_xml = LionPathXMLBuilder.new
    auth = {:username => Rails.application.config_for(:activity_insight)[:username],
            :password => Rails.application.config_for(:activity_insight)[:password]}
    url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
    counter = 0
    my_lp_xml.batched_lionpath_xml[0..100].each do |xml|
      puts xml
      response = HTTParty.post url, :body => xml, :headers => {'Content-type' => 'text/xml'}, :basic_auth => auth, :timeout => 180
      puts response
      if response.include? 'Error'
        counter += 1
      end
    end
    puts counter
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins')
  end

end

