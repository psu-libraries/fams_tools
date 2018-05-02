class AddForeignKeyContractFacultyLinks < ActiveRecord::Migration[5.1]
  def change
      add_foreign_key :contract_faculty_links, :contracts
      add_foreign_key :contract_faculty_links, :faculties
    end
  end

  def down
    remove_foreign_key contract_faculty_links, :contracts
  end
