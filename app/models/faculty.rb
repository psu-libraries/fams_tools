class Faculty < ApplicationRecord
  has_many :publication_faculty_links
  has_many :publications, through: :publication_faculty_links
  has_many :contracts, through: :contract_faculty_links
  has_many :courses, through: :sections
  has_many :contract_faculty_links
  has_many :sections
  has_many :presentations
  has_one :personal_contact
  has_many :gpas
end
