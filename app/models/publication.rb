class Publication < ApplicationRecord
  serialize :pure_ids, coder: YAML, type: Array
  serialize :ai_ids, coder: YAML, type: Array
  serialize :editors, coder: YAML, type: Array
  has_many :external_authors
  has_many :publication_faculty_links
  has_many :faculties, through: :publication_faculty_links
end
