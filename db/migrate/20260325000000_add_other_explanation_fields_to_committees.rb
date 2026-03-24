class AddOtherExplanationFieldsToCommittees < ActiveRecord::Migration[7.2]
  def change
    change_table :committees, bulk: true do |t|
      t.text :role_other_explanation, limit: 20_000
      t.text :type_other_explanation, limit: 20_000
    end
  end
end
