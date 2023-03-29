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
      departments {'{"ADMIN_DEP_1_DEP":"Dept 1",
        "ADMIN_DEP_1_DEP_OTHER":"Other 1",
        "ADMIN_DEP_2_DEP":"Dept 2",
        "ADMIN_DEP_2_DEP_OTHER":"Other 2",
        "ADMIN_DEP_3_DEP":"Dept 3",
        "ADMIN_DEP_3_DEP_OTHER":"Other 3"}'}
      title { 'Associate' }
      rank { 'Professor' }
      tenure { 'Tenured' }
      endowed_position { 'Associate Professor' }
      graduate { 'Yes' }
      time_status { 'Full-Time' }
      hr_code { 'ACT' }
    end
  end