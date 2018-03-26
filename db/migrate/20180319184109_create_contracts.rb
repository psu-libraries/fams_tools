class CreateContracts < ActiveRecord::Migration[5.1]
  def up
    create_table :contracts do |t|
      t.integer :osp_key
      t.string :title
      t.references :sponsor, foreign_key: true
      t.string :status
      t.string :submitted
      t.string :awarded
      t.integer :requested
      t.integer :funded
      t.integer :total_anticipated
      t.string :start_date
      t.string :end_date
      t.string :grant_contract
      t.string :base_agreement

    end
    add_index :contracts, :osp_key, unique: true
  end
  def down
    remove_column :contract_faculty_links, :contract_id
    drop_table :contracts
  end
end
