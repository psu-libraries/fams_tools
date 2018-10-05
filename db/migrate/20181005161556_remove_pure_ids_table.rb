class RemovePureIdsTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :pure_ids
  end
end
