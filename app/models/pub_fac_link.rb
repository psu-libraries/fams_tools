class PubFacLink < ApplicationRecord
  belongs_to :contract_id
  belongs_to :faculty_id
end
