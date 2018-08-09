class CreatePublications < ActiveRecord::Migration[5.1]
  def change
    create_table :publications do |t|
      t.bigint :faculty_id
      t.integer :pure_id
      t.text :title
      t.string :category
      t.integer :volume
      t.string :status
      t.integer :dty
      t.string :dtm
      t.integer :dtd
      t.string :journal_title
      t.string :journal_issn
      t.integer :journal_num
      t.string :journal_uuid
      t.string :pages
      t.integer :articleNumber
      t.string :peerReview
      t.string :url
      t.string :publisher

      t.timestamps
    end

    add_index :publications, :pure_id, unique: true
  end
end
