class CreateContractGrant < ActiveRecord::Migration[5.1]
  def change
    create_table :contract_grants do |t|
      t.integer :osp_key
      t.string :title
      t.string :sponsor
      t.string :sponsor_type
      t.string :access_id
      t.string :f_name
      t.string :l_name
      t.string :role
      t.integer :pct_credit
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
