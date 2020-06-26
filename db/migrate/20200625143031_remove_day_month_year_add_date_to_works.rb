class RemoveDayMonthYearAddDateToWorks < ActiveRecord::Migration[5.2]
  def self.up
    remove_column :works, :day
    remove_column :works, :month
    remove_column :works, :year
    add_column :works, :date, :string
  end

  def self.down
    add_column :works, :day, :integer
    add_column :works, :month, :integer
    add_column :works, :year, :integer
    remove_column :works, :date
  end
end
