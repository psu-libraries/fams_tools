class ChangeWorksColumns < ActiveRecord::Migration[5.1]
  def change
    remove_column :works, :date
    add_column :works, :year, :integer
    add_column :works, :month, :integer
    add_column :works, :day, :integer
  end
end
