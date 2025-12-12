class Faculty < ApplicationRecord
  has_many :publication_faculty_links
  has_many :publications, through: :publication_faculty_links
  has_many :contracts, through: :contract_faculty_links
  has_many :courses, through: :sections
  has_many :contract_faculty_links
  has_many :sections
  has_many :presentations
  has_one :personal_contact
  has_many :yearlies
  has_many :com_efforts
  has_many :com_qualities
  has_many :committees, dependent: :destroy
end
