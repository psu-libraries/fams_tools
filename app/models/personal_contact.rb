class PersonalContact < ApplicationRecord
  belongs_to :faculty

  validates :faculty_id, :uid, presence: true
  validates :faculty_id, uniqueness: true
end
