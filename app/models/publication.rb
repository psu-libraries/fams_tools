class Publication < ApplicationRecord
  serialize :pure_ids
  serialize :ai_ids
  has_many :external_authors
  has_many :publication_faculty_links
  has_many :faculties, through: :publication_faculty_links
end
