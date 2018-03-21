class CreateSponsors < ActiveRecord::Migration[5.1]
  def up
    create_table :sponsors do |t|
      t.string :sponsor_name
      t.string :sponsor_type

    end
    add_index :sponsors, :sponsor_name, unique: true
  end

  def down
    if ActiveRecord::Base.connection.data_source_exists? 'sponsors'
      drop_table :sponsors
    end
  end

end
