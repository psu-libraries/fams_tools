class ComEffort < ApplicationRecord
  belongs_to :com_effort
  attr_accessor :com_id, :course_year, :course, :event_type,
                :faculty_name, :event, :event_date, :hours
end
