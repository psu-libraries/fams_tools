class CreateUserNums < ActiveRecord::Migration[5.1]
  def change
    create_table :user_nums do |t|
      t.bigint :faculty_id
      t.integer :id_number
    end
  end
end
