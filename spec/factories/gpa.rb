FactoryBot.define do
  factory :gpa do
    faculty { create :faculty }
    semester { 'Spring' }
    year { DateTime.now.year }
    course_prefix { 'CRIM' }
    sequence(:course_number) { |n| "#{n}" }
    section_number { "001" }
    campus { 'UP' }
    number_of_grades { 15 }
    course_gpa { 3.5 }
    grade_dist_a { 10 }
    grade_dist_a_minus { 9 }
    grade_dist_b { 8 }
    grade_dist_b_minus { 7 }
    grade_dist_b_plus { 6 }
    grade_dist_c { 5 }
    grade_dist_c_plus { 4 }
    grade_dist_d { 3 }
    grade_dist_f { 2 }
    grade_dist_w { 1 }
    grade_dist_ld { 1 }
    grade_dist_other { 0 }
  end
end
