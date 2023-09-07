class CreateFaculties < ActiveRecord::Migration[5.1]
  def up
    create_table :faculties do |t|
      t.string :access_id
      t.bigint :user_id
      t.string :f_name
      t.string :l_name
      t.string :m_name
      t.string :college
    end
    add_index :faculties, :access_id, unique: true
  end

  def down
    drop_table :faculties
  end
end
