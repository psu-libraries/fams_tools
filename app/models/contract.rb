class Contract < ApplicationRecord
  has_many :pub_fac_links
  belongs_to :sponsor
end
