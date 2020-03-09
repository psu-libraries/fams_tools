require 'bibtex'

class Work < ApplicationRecord
  serialize :author
  serialize :editor
  belongs_to :publication_listing

  def self.to_csv
    SpreadsheetOutput.new(find_each).output
  end

  def self.to_bibtex
    BibtexOutput.new(find_each).output
  end

  def self.to_xlsx(axlsx_workbook)
    XLSXOutput.new(find_each).output(axlsx_workbook)
  end
end
