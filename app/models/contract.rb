class Contract < ApplicationRecord
  has_many :pub_fac_link_id
  belongs_to :sponsor_id
end
