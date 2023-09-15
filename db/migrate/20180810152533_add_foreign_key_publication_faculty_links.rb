class AddForeignKeyPublicationFacultyLinks < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :publication_faculty_links, :publications
    add_foreign_key :publication_faculty_links, :faculties
  end
end
