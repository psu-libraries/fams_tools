class CreatePublications < ActiveRecord::Migration[5.1]
  def change
    create_table :publications do |t|
      t.bigint :faculty_id
      t.string :title
      t.string :type
      t.string :volume
      t.integer :dty
      t.string :dtm
      t.string :dtd
      t.string :journal_title
      t.string :journal_issn
      t.string :journal_num
      t.string :pages

      t.timestamps
    end
  end
end
