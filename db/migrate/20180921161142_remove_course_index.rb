class RemoveCourseIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :courses, column: :academic_course_id
  end
end
