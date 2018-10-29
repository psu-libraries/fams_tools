class ChangeSecondaryTitlePublications < ActiveRecord::Migration[5.1]
  def change
    change_column :publications, :secondary_title, :text
  end
end
