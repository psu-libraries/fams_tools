require 'spreadsheet'
require 'csv'

class OspFormat

  #Creates CSV object.  Imported CSV MUST be tab delimited text.
  def self.csv_object
    CSV.read('data/dmresults-tabdel.txt', encoding: "ISO8859-1", col_sep: "\t")
  end



end
