class AddForeignKeyUserNums < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :user_nums, :faculties
  end

  def down
    remove_foreign_key :user_nums, :faculties
  end
end
