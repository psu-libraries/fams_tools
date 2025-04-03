class AddTimestampsToFaculties < ActiveRecord::Migration[7.0]
  def change
    add_timestamps :faculties, precision: nil, null: false
  end
end
