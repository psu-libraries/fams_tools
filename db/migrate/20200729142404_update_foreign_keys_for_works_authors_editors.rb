class UpdateForeignKeysForWorksAuthorsEditors < ActiveRecord::Migration[5.2]
  def self.up
    remove_foreign_key :works, :publication_listings
    remove_foreign_key :authors, :works
    remove_foreign_key :editors, :works
    add_foreign_key :works, :publication_listings, on_delete: :cascade
    add_foreign_key :authors, :works, on_delete: :cascade
    add_foreign_key :editors, :works, on_delete: :cascade
  end

  def self.down
    remove_foreign_key :works, :publication_listings
    remove_foreign_key :authors, :works
    remove_foreign_key :editors, :works
    add_foreign_key :works, :publication_listings
    add_foreign_key :authors, :works
    add_foreign_key :editors, :works
  end
end
