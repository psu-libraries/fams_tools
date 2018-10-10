class AddColumnAndIndexPublications < ActiveRecord::Migration[5.1]
  def change
    add_column :publications, :ai_ids, :string
    
    remove_index :publications, :pure_ids
    add_index :publications, [:pure_ids, :ai_ids], unique: true
  end
end
