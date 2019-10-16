class ChangeGpasColumns < ActiveRecord::Migration[5.1]
  def change
    change_column :gpas, :section_number, :string
    change_column :gpas, :course_number, :string
  end
end
