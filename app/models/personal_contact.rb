class PersonalContact < ApplicationRecord
  belongs_to :faculty

  validates :faculty_id, presence: true
end
