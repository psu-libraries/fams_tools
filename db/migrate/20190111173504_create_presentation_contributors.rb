class CreatePresentationContributors < ActiveRecord::Migration[5.1]
  def change
    create_table :presentation_contributors do |t|
      t.bigint :presentation_id, null: false
      t.string :f_name
      t.string :m_name
      t.string :l_name
    end

    add_index :presentation_contributors, :presentation_id

    add_foreign_key :presentation_contributors, :presentations, on_delete: :cascade
  end
end
