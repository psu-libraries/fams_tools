class Faculty < ApplicationRecord
  has_many :contracts, through: :pub_fac_links
  has_many :pub_fac_links
end
