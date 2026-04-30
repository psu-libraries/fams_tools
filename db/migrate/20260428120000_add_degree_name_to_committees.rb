class AddDegreeNameToCommittees < ActiveRecord::Migration[7.2]
  def change
    add_column :committees, :degree_name, :string
  end
end
