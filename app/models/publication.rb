class Publication < ApplicationRecord
  has_many :external_authors
  belongs_to :faculty
end
