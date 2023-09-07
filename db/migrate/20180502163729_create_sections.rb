class CreateSections < ActiveRecord::Migration[5.1]
  def up
    create_table :sections do |t|
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
      t.string :instructor_role
      t.string :course_component
      t.string :xcourse_course_pre
      t.integer :xcourse_course_num
      t.string :xcourse_course_suf
      t.bigint :course_id
      t.bigint :faculty_id
    end
  end

  def down
    drop_table :sections
  end
end
