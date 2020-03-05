require 'bibtex'

class Work < ApplicationRecord
  serialize :author
  serialize :editor
  belongs_to :publication_listing

  def self.to_csv
    CSVOutput.new(all).output
  end

  def self.to_bibtex
    BibtexOutput.new(all).output
  end
end
