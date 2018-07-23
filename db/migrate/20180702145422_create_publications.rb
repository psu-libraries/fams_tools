class CreatePublications < ActiveRecord::Migration[5.1]
  def change
    create_table :publications do |t|
      t.bigint :faculty_id
      t.text :title
      t.string :cattype
      t.integer :volume
      t.string :status
      t.integer :dty
      t.string :dtm
      t.integer :dtd
      t.string :journal_title
      t.string :journal_issn
      t.integer :journal_num
      t.string :pages
      t.integer :articleNumber
      t.boolean :peerReview
      t.string :url

      t.timestamps
    end
  end
end
