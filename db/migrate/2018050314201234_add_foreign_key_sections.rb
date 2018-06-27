class AddForeignKeySections < ActiveRecord::Migration[5.1]
  def change
      add_foreign_key :sections, :courses
      add_foreign_key :sections, :faculties
  end
end
