class CreateContractFacultyLink < ActiveRecord::Migration[5.1]
  def change
    create_table :contract_faculty_links do |t|
      t.references :contract, foreign_key: true
      t.references :faculty, foreign_key: true
      t.string :role
      t.integer :pct_credit

      t.timestamps
    end
  end
end
