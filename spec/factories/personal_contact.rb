FactoryBot.define do
  factory :personal_contact do
    faculty { create :faculty }
    uid { 'abc123' }
    telephone_number { '+1 123 456 7891' }
    postal_address { 'Test Address' }
    department { 'Test Department' }
    title { 'Test Title' }
    ps_research { 'Test research interests.' }
    ps_teaching { 'Test teaching interests.' }
    ps_office_address { '123 Test Office Address' }
    facsimile_telephone_number { 'Test FAX' }
    cn { 'Test User Person' }
    mail { 'abc123@psu.edu' }
    personal_web { 'www.personal.website' }
  end
end
