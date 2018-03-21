class CreateFaculties < ActiveRecord::Migration[5.1]
  def up
    create_table :faculties do |t|
      t.string :access_id
      t.string :f_name
      t.string :l_name

    end
    add_index :faculties, :access_id, unique: true
  end

  def down
    if ActiveRecord::Base.connection.data_source_exists? 'faculties'
      drop_table :faculties
    end
  end
end
