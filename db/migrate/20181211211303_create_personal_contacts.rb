class CreatePersonalContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :personal_contacts do |t|
      t.bigint :faculty_id, null: false
      t.string :telephone_number
      t.string :postal_address
      t.string :department
      t.string :title
      t.string :ps_research
      t.string :ps_teaching
      t.string :ps_office_address
      t.string :facsimile_telephone_number
      t.string :cn
      t.string :mail
      t.timestamps
    end

    add_index :personal_contacts, :faculty_id

    add_foreign_key :personal_contacts, :faculties
  end
end
