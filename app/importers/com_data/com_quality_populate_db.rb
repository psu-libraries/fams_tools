require 'com_data/com_parser'

class ComData::ComQualityPopulateDb
  attr_accessor :com_parser

  def initialize(com_parser_obj = ComData::ComParser.new)
    @com_parser = com_parser_obj
  end

  def populate
    com_parser.csv_hash.each do |row|
      begin
        ComQuality.create(com_id:           row['FACULTY_USERNAME'],
                          course_year:      row['COURSE_YEAR'],
                          course:           row['COURSE'],
                          event_type:       row['EVENT_TYPE'],
                          faculty_name:     row['FACULTY_NAME'],
                          evaluation_type:  row['EVALUATION_TYPE'],
                          average_rating:   row['UME_AVERAGE_RATING'],
                          num_evaluations:  row['NUMBER_OF_EVALUATIONS'])
        rescue ActiveRecord::RecordNotUnique
      end
    end
  end

end
