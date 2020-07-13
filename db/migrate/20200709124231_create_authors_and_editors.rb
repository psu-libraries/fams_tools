class CreateAuthorsAndEditors < ActiveRecord::Migration[5.2]
  def self.up
    create_table :authors do |t|
      t.string :f_name
      t.string :m_name
      t.string :l_name
      t.bigint :work_id
    end

    create_table :editors do |t|
      t.string :f_name
      t.string :m_name
      t.string :l_name
      t.bigint :work_id
    end

    add_foreign_key :authors, :works
    add_foreign_key :editors, :works
  end

  def self.down
    drop_table :authors
    drop_table :editors
    remove_foreign_key :authors, :works
    remove_foreign_key :editors, :works
  end
end
