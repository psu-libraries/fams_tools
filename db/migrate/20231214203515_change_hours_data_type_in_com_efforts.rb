class ChangeHoursDataTypeInComEfforts < ActiveRecord::Migration[7.0]
  def up
    change_column :com_efforts, :hours, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :com_efforts, :hours, :integer
  end
end
