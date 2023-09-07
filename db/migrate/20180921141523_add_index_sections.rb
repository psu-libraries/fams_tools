class AddIndexSections < ActiveRecord::Migration[5.1]
  def change
    add_index :sections,
              %w[faculty_id course_id class_campus_code subject_code course_number course_suffix class_section_code course_component], unique: true, name: 'pkey', length: { 'class_campus_code' => 50, 'subject_code' => 50, 'course_suffix' => 50, 'class_section_code' => 50, 'course_component' => 50 }
  end
end
