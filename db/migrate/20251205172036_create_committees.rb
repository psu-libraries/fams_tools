class CreateCommittees < ActiveRecord::Migration[7.2]
  def change
    create_table :committees do |t|
      t.references :faculty, null: false, foreign_key: true
      t.string :student_name
      t.string :role
      t.string :thesis_title
      t.string :degree_type

      t.timestamps
    end
  end
end

