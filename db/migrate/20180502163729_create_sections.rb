class CreateSections < ActiveRecord::Migration[5.1]
  def up
    create_table :sections do |t|
      t.references :course, foreign_key: true
      t.references :faculty, foreign_key: true
      t.string :class_campus_code
      t.string :cross_listed_flag
      t.integer :course_number
      t.string :course_suffix
      t.string :subject_code
      t.string :class_section_code
      t.string :course_credits
      t.integer :current_enrollment
      t.integer :instructor_load_factor
      t.string :instruction_mode
      t.string :course_component
      t.string :xcourse_course_pre
      t.integer :xcourse_course_num
      t.string :xcourse_course_suf
    end
  end
  def down
    drop_table :sections
  end
end
