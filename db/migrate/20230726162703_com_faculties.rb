class ComFaculties < ActiveRecord::Migration[7.0]
  def self.up
    add_column :faculties, :com_id, :string

    add_column :com_efforts, :faculty_id, :bigint
    add_column :com_qualities, :faculty_id, :bigint

    add_foreign_key :com_efforts, :faculties
    add_foreign_key :com_qualities, :faculties
  end

  def self.down
    remove_column :faculties, :com_id, :string

    remove_foreign_key :com_efforts, :faculties
    remove_foreign_key :com_qualities, :faculties

    remove_column :com_efforts, :faculty_id
    remove_column :com_qualities, :faculty_id
  end
end
