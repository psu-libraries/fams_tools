class PersonalContact < ApplicationRecord
  belongs_to :faculty

  validates :faculty_id, :uid, presence: true
end
