class AddMonthsToCommittees < ActiveRecord::Migration[7.2]
  def change
    change_table :committees, bulk: true do |t|
      t.integer :start_month
      t.integer :completion_month
    end
  end
end
