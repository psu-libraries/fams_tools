class RemoveDepsFromYearly < ActiveRecord::Migration[7.0]
  def self.up
    remove_column :yearlies, :admin_dept1
    remove_column :yearlies, :admin_dept1_other
    remove_column :yearlies, :admin_dept2
    remove_column :yearlies, :admin_dept2_other
    remove_column :yearlies, :admin_dept3
    remove_column :yearlies, :admin_dept3_other
    add_column :yearlies, :departments, :json
  end

  def self.down
    add_column :yearlies, :admin_dept1, :string
    add_column :yearlies, :admin_dept1_other, :string
    add_column :yearlies, :admin_dept2, :string
    add_column :yearlies, :admin_dept2_other, :string
    add_column :yearlies, :admin_dept3, :string
    add_column :yearlies, :admin_dept3_other, :string
    remove_column :yearlies, :departments, :json
  end
end
