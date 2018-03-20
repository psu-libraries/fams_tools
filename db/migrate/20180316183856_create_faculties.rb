class CreateFaculties < ActiveRecord::Migration[5.1]
  def change
    create_table :faculties do |t|
      t.string :access_id
      t.string :f_name
      t.string :l_name
      
      t.timestamps
    end
  end
end
