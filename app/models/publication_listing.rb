class PublicationListing < ApplicationRecord
  has_many :works, dependent: :delete_all
  accepts_nested_attributes_for :works, reject_if: :all_blank, allow_destroy: true
end
