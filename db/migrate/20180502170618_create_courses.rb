class CreateCourses < ActiveRecord::Migration[5.1]
  def up
    create_table :courses do |t|
      t.integer :academic_course_id
      t.string :term
      t.integer :calendar_year
      t.string :course_short_description
      t.text :course_long_description

    end
    add_index :courses, :academic_course_id, unique: true
  end
  def down
    drop_table :courses 
  end
end
