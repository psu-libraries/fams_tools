class RemoveNullFalseFromFaculties < ActiveRecord::Migration[7.2]
  def change
    change_column_null(:faculties, :created_at, true)
    change_column_null(:faculties, :updated_at, true)
  end
end
