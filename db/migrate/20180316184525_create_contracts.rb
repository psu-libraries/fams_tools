class CreateContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :contracts do |t|
      t.string :title
      t.references :pub_fac_link_id, foreign_key: true
      t.references :sponsor_id, foreign_key: true
      t.string :status
      t.integer :osp_key
      t.date :submitted
      t.date :awarded
      t.integer :requested
      t.integer :funded
      t.integer :total_anticipated
      t.date :start_date
      t.date :end_date
      t.string :grant_contract
      t.string :base_agreement

      t.timestamps
    end
  end
end
