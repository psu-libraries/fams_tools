class CreatePublicationListings < ActiveRecord::Migration[5.1]
  def change
    create_table :publication_listings do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
