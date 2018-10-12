class AddColumnAndIndexPublications < ActiveRecord::Migration[5.1]
  def change
    add_column :publications, :ai_ids, :string
    add_column :publications, :pure_ids, :string
    
    remove_index :publications, :pure_id
    add_index :publications, [:pure_ids, :ai_ids], unique: true
  end
end
