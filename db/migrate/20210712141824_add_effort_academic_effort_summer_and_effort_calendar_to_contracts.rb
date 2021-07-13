class AddEffortAcademicEffortSummerAndEffortCalendarToContracts < ActiveRecord::Migration[5.2]
  def up
    add_column :contracts, :effort_academic, :float
    add_column :contracts, :effort_summer, :float
    add_column :contracts, :effort_calendar, :float
  end

  def down
    remove_column :contracts, :effort_academic
    remove_column :contracts, :effort_summer
    remove_column :contracts, :effort_calendar
  end
end
