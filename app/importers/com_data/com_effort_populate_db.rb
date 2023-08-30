require 'com_data/com_parser'

class ComData::ComEffortPopulateDb
  attr_accessor :com_parser

  def initialize(com_parser_obj = ComData::ComParser.new)
    @com_parser = com_parser_obj
  end

  def populate
    com_parser.csv_hash.each do |row|
      faculty = Faculty.find_by(com_id: row['FACULTY_USERNAME'].downcase)
      next if faculty.blank?

      begin
        com_effort = ComEffort.find_or_initialize_by( com_id:         row['FACULTY_USERNAME'],
                                                      course_year:    row['COURSE_YEAR'],
                                                      course:         row['COURSE'],
                                                      event_type:     row['EVENT_TYPE'],
                                                      faculty_name:   row['FACULTY_NAME'],
                                                      event:          row['EVENT'],
                                                      faculty:        faculty)

        com_effort.hours ||= 0
        com_effort.hours += row['UME_CALCULATED_TEACHING_WHILE_NON_BILLING_EFFORT__HRS_'].to_f

        com_effort.save!

      rescue ActiveRecord::RecordNotUnique
      end
    end
  end

end
