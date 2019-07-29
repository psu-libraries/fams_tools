class PublicationListing < ApplicationRecord
  has_many :works, dependent: :delete_all
end
