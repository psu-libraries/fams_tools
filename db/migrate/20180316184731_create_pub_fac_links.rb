class CreatePubFacLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :pub_fac_links do |t|
      t.references :contract_id, foreign_key: true
      t.references :faculty_id, foreign_key: true
      t.string :role
      t.integer :pct_credit

      t.timestamps
    end
  end
end
