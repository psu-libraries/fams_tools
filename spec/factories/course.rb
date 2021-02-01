FactoryBot.define do
  factory :course do
    term { 'Spring' }
    calendar_year { DateTime.now.year }
    course_short_description { 'Short Description' }
    course_long_description { 'Long Description' }
  end
end
