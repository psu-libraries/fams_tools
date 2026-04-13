class RemoveDegreeTypeAndRoleOtherFromCommittees < ActiveRecord::Migration[7.0]
  def change
    remove_column :committees, :degree_type, :string
  end
end
