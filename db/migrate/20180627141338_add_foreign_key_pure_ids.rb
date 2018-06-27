class AddForeignKeyPureIds < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :pure_ids, :faculties
  end
end
