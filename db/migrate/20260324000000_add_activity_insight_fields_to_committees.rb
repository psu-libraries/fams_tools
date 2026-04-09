class AddActivityInsightFieldsToCommittees < ActiveRecord::Migration[7.2]
  def change
    change_table :committees, bulk: true do |t|
      t.string :type_of_work
      t.string :stage_of_completion
      t.integer :start_year
      t.integer :completion_year
    end
  end
end
