class CreateIntegrations < ActiveRecord::Migration[5.2]
  def self.up
    create_table :integrations do |t|
      t.string :process_type
      t.boolean :is_active

      t.timestamps
    end
  end

  def self.down
    drop_table :integrations
  end
end
