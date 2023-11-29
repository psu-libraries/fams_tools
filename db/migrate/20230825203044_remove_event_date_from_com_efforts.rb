class RemoveEventDateFromComEfforts < ActiveRecord::Migration[7.0]
  def self.up
    remove_index :com_efforts, name: 'index_com_efforts_on_com_id_and_course_and_event_and_event_date'
    remove_column :com_efforts, :event_date
    add_index :com_efforts, %w[com_id course event], unique: true, length: { 'course' => 50, 'event' => 50 }
  end

  def self.down
    remove_index :com_efforts, name: 'index_com_efforts_on_com_id_and_course_and_event'
    add_column :com_efforts, :event_date, :string
    add_index :com_efforts, %w[com_id course event event_date], unique: true,
                                                                length: { 'course' => 50, 'event' => 50 }
  end
end
