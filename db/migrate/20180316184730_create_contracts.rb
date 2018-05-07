class CreateContracts < ActiveRecord::Migration[5.1]
  def up
    create_table :contracts do |t|
      t.integer :osp_key
      t.string :title
      t.bigint :sponsor_id
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

    end
    add_index :contracts, :osp_key, unique: true
  end
  def down
    drop_table :contracts
  end
end
