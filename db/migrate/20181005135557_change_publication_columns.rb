class ChangePublicationColumns < ActiveRecord::Migration[5.1]
  def change
    change_column :publications, :pure_id, :string
    remove_column :publications, :peerReview, :string
    remove_column :publications, :url, :string
    rename_column :publications, :journal_num, :issue
    rename_column :publications, :pages, :page_range
    add_column :publications, :edition, :integer
    add_column :publications, :abstract, :text
    add_column :publications, :secondary_title, :string
    add_column :publications, :citation_count, :integer
    add_column :publications, :authors_et_al, :boolean
  end
end
