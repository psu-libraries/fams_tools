class CreateContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :contracts do |t|
      t.integer :osp_key
      t.string :title
      t.references :sponsor, foreign_key: true
      t.string :status
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
