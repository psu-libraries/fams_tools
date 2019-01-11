class CreatePresentations < ActiveRecord::Migration[5.1]
  def change
    create_table :presentations do |t|
      t.bigint :faculty_id, null: false
      t.string :title
      t.date :dty_date
      t.string :name
      t.string :org
      t.string :location
    end

    add_index :presentations, :faculty_id

    add_foreign_key :presentations, :faculties, on_delete: :cascade
  end
end
