class AddCitationToWorks < ActiveRecord::Migration[5.2]
  def self.up
    add_column :works, :citation, :text
  end

  def self.down
    remove_column :works, :citation
  end
end
