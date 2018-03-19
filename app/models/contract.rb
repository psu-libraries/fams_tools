class Contract < ApplicationRecord
  has_many :faculties, through: :pub_fac_links
  has_many :pub_fac_links
  belongs_to :sponsor
end
