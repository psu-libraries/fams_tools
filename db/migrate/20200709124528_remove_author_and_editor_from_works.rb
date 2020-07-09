class RemoveAuthorAndEditorFromWorks < ActiveRecord::Migration[5.2]
  def self.up
    remove_column :works, :author
    remove_column :works, :editor
  end

  def self.down
    add_column :works, :author, :text
    add_column :works, :editor, :text
  end
end
