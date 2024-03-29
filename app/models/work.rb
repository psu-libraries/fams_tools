require 'concerns/xlsx_output'

class Work < ApplicationRecord
  belongs_to :publication_listing
  has_many :authors, dependent: :delete_all
  accepts_nested_attributes_for :authors, reject_if: :all_blank, allow_destroy: true
  has_many :editors, dependent: :delete_all
  accepts_nested_attributes_for :editors, reject_if: :all_blank, allow_destroy: true

  def self.to_csv
    SpreadsheetOutput.new(find_each).output
  end

  def self.to_xlsx(axlsx_workbook)
    XlsxOutput.new(find_each).output(axlsx_workbook)
  end
end
