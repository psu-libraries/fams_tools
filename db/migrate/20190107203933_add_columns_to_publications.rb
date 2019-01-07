class AddColumnsToPublications < ActiveRecord::Migration[5.1]
  def change
    add_column :publications, :web_address, :string
    add_column :publications, :editors, :text
    add_column :publications, :institution, :string
    add_column :publications, :isbnissn, :string
    add_column :publications, :pubctyst, :string
  end
end
