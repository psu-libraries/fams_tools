FactoryBot.define do
    factory :yearly do
      faculty { create :faculty }
      academic_year { '2023-2024' }
      campus { 'UP' }
      campus_name { 'University Park' }
      college { 'EN' }
      college_name { 'College of Engineering' }
      school { 'School' }
      division { 'Division' }
      institute { 'Institute' }
      admin_dept1 { 'Dept 1' }
      admin_dept1_other { 'Other 1' }
      admin_dept2 { 'Dept 2' }
      admin_dept2_other { 'Other 2' }
      admin_dept3 { 'Dept 3' }
      admin_dept3_other { 'Other 3' }
      title { 'Associate' }
      rank { 'Professor' }
      tenure { 'Tenured' }
      endowed_position { 'Associate Professor' }
      graduate { 'Yes' }
      time_status { 'Full-Time' }
      hr_code { 'ACT' }
    end
  end