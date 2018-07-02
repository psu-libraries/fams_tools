class AddForeignKeyExternalAuthors < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :external_authors, :publications
  end
end
