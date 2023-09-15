class CreateGpas < ActiveRecord::Migration[5.1]
  def change
    create_table :gpas do |t|
      t.references :faculty, foreign_key: true
      t.string :semester
      t.integer :year
      t.string :course_prefix
      t.integer :course_number
      t.string :course_number_suffix
      t.integer :section_number
      t.string :campus
      t.integer :number_of_grades
      t.integer :course_gpa
      t.integer :grade_dist_a
      t.integer :grade_dist_a_minus
      t.integer :grade_dist_b_plus
      t.integer :grade_dist_b
      t.integer :grade_dist_b_minus
      t.integer :grade_dist_c_plus
      t.integer :grade_dist_c
      t.integer :grade_dist_d
      t.integer :grade_dist_f
      t.integer :grade_dist_w
      t.integer :grade_dist_ld
      t.integer :grade_dist_other

      t.timestamps
    end

    add_index :gpas,
              %w[faculty_id semester year course_prefix course_number course_number_suffix section_number campus], unique: true, name: 'unique_key', length: { 'semester' => 50, 'course_prefix' => 50, 'course_number_suffix' => 50, 'campus' => 50 }
  end
end
