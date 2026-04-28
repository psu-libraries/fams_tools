class AddRoleOtherToCommittees < ActiveRecord::Migration[7.2]
  def change
    add_column :committees, :role_other, :string
  end
end
