class DeletePublicationIdsAndIndex < ActiveRecord::Migration[7.0]
  def up
    remove_index :publications, %i[pure_ids ai_ids]
    change_table :publications, bulk: true do |t|
      t.remove :pure_id
      t.remove :ai_ids
      t.remove :pure_ids
    end
  end

  def down
    change_table :publications, bulk: true do |t|
      t.string :pure_id
      t.string :ai_ids
      t.string :pure_ids
    end

    add_index :publications, %i[pure_ids ai_ids] unless index_exists?(:publications, %i[pure_ids ai_ids])
  end
end
