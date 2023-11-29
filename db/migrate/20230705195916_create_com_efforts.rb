class CreateComEfforts < ActiveRecord::Migration[7.0]
  def change
    create_table :com_efforts do |t|
      t.timestamps
      t.string :com_id
      t.string :course_year
      t.string :course
      t.string :event_type
      t.string :faculty_name
      t.string :event
      t.string :event_date
      t.integer :hours
    end
    add_index :com_efforts, %w[com_id course event event_date], unique: true,
                                                                length: { 'course' => 50, 'event' => 50 }
  end
end
