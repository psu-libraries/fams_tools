class DeletePublicationIdsAndIndex < ActiveRecord::Migration[7.0]
  def change
    remove_column :publications, :pure_id
    remove_index :publications, %i[pure_ids ai_ids]
    remove_column :publications, :ai_ids
    remove_column :publications, :pure_ids
  end
end
