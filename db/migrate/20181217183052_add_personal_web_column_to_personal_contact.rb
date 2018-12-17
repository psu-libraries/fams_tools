class AddPersonalWebColumnToPersonalContact < ActiveRecord::Migration[5.1]
  def change
    add_column :personal_contacts, :personal_web, :string
  end
end
