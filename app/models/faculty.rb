class Faculty < ApplicationRecord
  has_many :contracts, through: :contract_faculty_links
  has_many :courses, through: :sections
  has_many :contract_faculty_links
  has_many :sections
  has_one :user_num
end
