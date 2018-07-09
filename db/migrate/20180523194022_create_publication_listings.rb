class CreatePublicationListings < ActiveRecord::Migration[5.1]
  def change
    create_table :publication_listings do |t|
      t.string :path
      t.string :type

      t.timestamps
    end
  end
end
