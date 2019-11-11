FactoryBot.define do
  factory :faculty do
    sequence(:access_id) { |n| 'abc' + n.to_s }
    sequence(:user_id) { |n| n }
    f_name { 'Test' }
    l_name { 'User' }
    m_name { 'Person' }
    college { 'EN' }
    campus { 'UP' }
  end
end
