class ChangeDtyDateToString < ActiveRecord::Migration[5.1]
  def change
    change_column :presentations, :dty_date, :string
  end
end
