class AddUidColumnToPersonalContacts < ActiveRecord::Migration[5.1]
  def change
    add_column :personal_contacts, :uid, :string, null: false
  end
end
