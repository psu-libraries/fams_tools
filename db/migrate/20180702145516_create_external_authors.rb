class CreateExternalAuthors < ActiveRecord::Migration[5.1]
  def change
    create_table :external_authors do |t|
      t.bigint :publication_id
      t.string :f_name
      t.string :m_name
      t.string :l_name
      t.string :role

      t.timestamps
    end
  end
end
