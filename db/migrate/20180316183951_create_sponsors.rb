class CreateSponsors < ActiveRecord::Migration[5.1]
  def change
    create_table :sponsors do |t|
      t.string :sponsor_name
      t.string :sponsor_type

      t.timestamps
    end
  end
end
