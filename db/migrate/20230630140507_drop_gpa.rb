class DropGpa < ActiveRecord::Migration[7.0]
  def change
    drop_table :gpas, if_exists: true
  end
end
