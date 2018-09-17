class AddUsernameWorks < ActiveRecord::Migration[5.1]
  def change
    add_column :works, :username, :string
  end
end
