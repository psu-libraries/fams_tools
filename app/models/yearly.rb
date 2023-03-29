class Yearly < ApplicationRecord
  belongs_to :faculty

  def departments
    JSON.parse(super)
  end
end