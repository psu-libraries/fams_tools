class Course < ApplicationRecord
  has_many :faculties, through: :sections
  has_many :sections
end
