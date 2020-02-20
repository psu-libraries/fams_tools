FactoryBot.define do
  factory :integration do
    process_type { 'integration' }
    is_active { false }
  end
end
