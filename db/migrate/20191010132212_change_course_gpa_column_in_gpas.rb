class ChangeCourseGpaColumnInGpas < ActiveRecord::Migration[5.1]
  def change
    change_column :gpas, :course_gpa, :float
  end
end
