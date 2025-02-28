class AddRmdIdToPublication < ActiveRecord::Migration[7.0]
  def change
    add_column :publications, :rmd_id, :bigint
  end
end
