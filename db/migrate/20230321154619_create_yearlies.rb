class CreateYearlies < ActiveRecord::Migration[7.0]
  def change
    create_table :yearlies do |t|
      t.references :faculty, foreign_key: true, index: { unique: true }
      t.string :academic_year
      t.string :campus
      t.string :campus_name
      t.string :college
      t.string :college_name
      t.string :school
      t.string :division
      t.string :institute
      t.string :admin_dept1
      t.string :admin_dept1_other
      t.string :admin_dept2
      t.string :admin_dept2_other
      t.string :admin_dept3
      t.string :admin_dept3_other
      t.string :title
      t.string :rank
      t.string :tenure
      t.string :endowed_position
      t.string :graduate
      t.string :time_status
      t.string :hr_code
    end
  end
end
