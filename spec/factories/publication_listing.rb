FactoryBot.define do
  factory :publication_listing do
    sequence(:name) { |n| 'Name' + n.to_s }
    type { nil }
  end
end
