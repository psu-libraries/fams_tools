class Contract < ApplicationRecord
  has_many :faculties, through: :contract_faculty_links
  has_many :contract_faculty_links
  belongs_to :sponsor
end
