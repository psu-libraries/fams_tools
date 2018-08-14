class Publication < ApplicationRecord
  has_many :external_authors
  has_many :publication_faculty_links
  has_many :faculties, through: :publication_faculty_links
end
