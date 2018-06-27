class CreatePureIds < ActiveRecord::Migration[5.1]
  def change
    create_table :pure_ids do |t|
      t.bigint :pure_id
      t.bigint :faculty_id

      t.timestamps
    end
  end
end
