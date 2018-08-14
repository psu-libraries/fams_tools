class CreatePublicationFacultyLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :publication_faculty_links do |t|
      t.bigint :faculty_id
      t.bigint :publication_id
      t.string :category
      t.string :dtm
      t.string :status

      t.timestamps
    end
  end
end
