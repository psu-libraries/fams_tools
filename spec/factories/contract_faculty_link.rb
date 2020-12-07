FactoryBot.define do
  factory :contract_faculty_link do
    role { 'Principal Investigator' }
    pct_credit { 50 }
    faculty
    contract
  end
end
