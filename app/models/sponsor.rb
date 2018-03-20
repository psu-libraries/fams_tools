class Sponsor < ApplicationRecord
  has_many :contracts, :uniq => true
end
