class RemoveDegreeTypeAndRoleOtherFromCommittees < ActiveRecord::Migration[7.0]
  def change
    change_table :committees, bulk: true do |t|
      t.remove :degree_type, type: :string
      t.remove :role_other_explanation, type: :text
    end
  end
end
