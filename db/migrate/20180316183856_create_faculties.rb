class CreateFaculties < ActiveRecord::Migration[5.1]
  def change
    create_table :faculties do |t|
      t.string :f_name
      t.string :l_name
      t.string :username
      t.references :pub_fac_link, foreign_key: true

      t.timestamps
    end
  end
end
