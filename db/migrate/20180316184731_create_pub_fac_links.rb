class CreatePubFacLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :pub_fac_links do |t|
      t.references :contract, foreign_key: true
      t.references :faculty, foreign_key: true
      t.string :role
      t.integer :pct_credit

      t.timestamps
    end
  end
end
