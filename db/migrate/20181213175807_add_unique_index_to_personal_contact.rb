class AddUniqueIndexToPersonalContact < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :personal_contacts, column: :faculty_id
    remove_index :personal_contacts, :faculty_id
    add_foreign_key :personal_contacts, :faculties
    add_index :personal_contacts, :faculty_id, unique: true
  end
end
