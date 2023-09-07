class CreateContractFacultyLinks < ActiveRecord::Migration[5.1]
  def up
    create_table :contract_faculty_links do |t|
      t.string :role
      t.integer :pct_credit
      t.bigint :contract_id
      t.bigint :faculty_id
    end
    add_index :contract_faculty_links, %i[contract_id faculty_id], unique: true
  end

  def down
    drop_table :contract_faculty_links
  end
end
