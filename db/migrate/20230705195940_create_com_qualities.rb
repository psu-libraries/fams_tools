class CreateComQualities < ActiveRecord::Migration[7.0]
  def change
    create_table :com_qualities do |t|
      t.timestamps
      t.string :com_id
      t.string :course_year
      t.string :course
      t.string :event_type
      t.string :faculty_name
      t.string :evaluation_type
      t.float :average_rating
      t.integer :num_evaluations
    end
    add_index :com_qualities, %w[com_id course course_year], unique: true
  end
end
