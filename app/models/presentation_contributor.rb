class PresentationContributor < ApplicationRecord
  belongs_to :presentation

  validates :presentation_id, presence: true
end
