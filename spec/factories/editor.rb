FactoryBot.define do
  factory :editor do
    sequence(:f_name) { |n| "Test_#{n}" }
    l_name { 'User' }
    m_name { 'Person' }
    work { create :work }
  end
end
