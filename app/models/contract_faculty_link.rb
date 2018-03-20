class ContractFacultyLink < ApplicationRecord
  belongs_to :contract
  belongs_to :faculty
end
