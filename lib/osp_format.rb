require 'spreadsheet'
require 'csv'

class OspFormat

  #Creates CSV object.  Imported CSV MUST be tab delimited text.
  def self.csv_object
    CSV.read('data/dmresults-tabdel.txt', encoding: "ISO8859-1", col_sep: "\t")
  end

  #Converts calendar dates back to accessids
  def self.convert_date_to_id
    self.csv_object.each do |csv|
      if csv[6].include? '-'
        unless csv[6][0..0] =~ /[A-Z]/
          csv[6] = csv[6].split('-').reverse.join("").downcase
        else
          csv[6] = csv[6].split('-').join("").downcase
        end
      end
    end
  end

end

