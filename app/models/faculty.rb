class Faculty < ApplicationRecord
  has_many :contracts, through: :contract_faculty_links
  has_many :contract_faculty_links
end
