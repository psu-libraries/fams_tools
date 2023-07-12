class ComQuality < ApplicationRecord
  belongs_to :com_quality
  attr_accessor :com_id, :course_year, :course, :event_type,
                :faculty_name, :evaluation_type, :average_rating, :num_evaluations
end
