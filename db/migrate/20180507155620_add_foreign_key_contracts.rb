class AddForeignKeyContracts < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :contracts, :sponsors
  end

  def down
    remove_foreign_key :contracts, :sponsors
  end
end
