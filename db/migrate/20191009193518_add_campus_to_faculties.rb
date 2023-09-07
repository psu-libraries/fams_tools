class AddCampusToFaculties < ActiveRecord::Migration[5.1]
  def change
    add_column :faculties, :campus, :string
  end
end
