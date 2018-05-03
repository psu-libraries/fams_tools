class AddForeignKeySections < ActiveRecord::Migration[5.1]
  def change
      add_foreign_key :sections, :courses
      add_foreign_key :sections, :faculties
    end
  end

  def down
    remove_foreign_key sections, :courses
    remove_foreign_key sections, :faculties
  end
