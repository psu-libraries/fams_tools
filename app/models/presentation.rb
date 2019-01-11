class Presentation < ApplicationRecord
  belongs_to :faculty
  has_many :presentation_contributors

  validates :faculty_id, presence: true
end
