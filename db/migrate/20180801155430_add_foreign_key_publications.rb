class AddForeignKeyPublications < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :publications, :faculties
  end
end
