class CreateContractFacultyLinks < ActiveRecord::Migration[5.1]
  def up
    create_table :contract_faculty_links do |t|
      t.string :role
      t.integer :pct_credit
      t.bigint :contract_id
    end
  end
  def down
    drop_table :contract_faculty_links
  end
end
