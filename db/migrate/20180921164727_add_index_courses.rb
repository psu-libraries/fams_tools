class AddIndexCourses < ActiveRecord::Migration[5.1]
  def change
    add_index :courses, %w[academic_course_id term calendar_year], unique: true
  end
end
