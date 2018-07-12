class CreateWorks < ActiveRecord::Migration[5.1]
  def change
    create_table :works do |t|
      t.references :publication_listing, foreign_key: true
      t.text :author
      t.string :title
      t.string :journal
      t.string :volume
      t.string :edition
      t.string :pages
      t.string :date
      t.string :item
      t.string :booktitle
      t.string :container
      t.string :doi
      t.string :editor
      t.string :institution
      t.string :isbn
      t.string :location
      t.string :note
      t.string :publisher
      t.string :retrieved
      t.string :tech
      t.string :translator
      t.string :unknown
      t.string :url

      t.timestamps
    end
  end
end
