FactoryBot.define do
  factory :section do
    course
    faculty
    class_campus_code { 'UP' }
    cross_listed_flag { 'N' }
    subject_code { 'ABC' }
    course_number { '100' }
    course_suffix { 'A' }
    class_section_code { '001' }
    course_credits { '3' }
    current_enrollment { '10' }
    instructor_load_factor { '100' }
    instruction_mode { 'In Person' }
    instructor_role { 'Primary Instructor' }
    course_component { 'Lecture' }
    xcourse_course_pre { '' }
    xcourse_course_num { '' }
    xcourse_course_suf { '' }
  end
end
