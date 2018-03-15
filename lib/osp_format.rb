require 'spreadsheet'
require 'csv'

class OspFormat

  #Creates CSV object.  Imported CSV must be tab delimited text.
  def self.csv_object
    CSV.read('data/dmresults-tabdel.txt', encoding: "ISO8859-1", col_sep: "\t")
  end

  #Converts calendar dates back to accessids
  def self.format_accessid_field
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

  #Removes time and '/ /' from date fields
  def self.format_date_fields
    self.csv_object.each do |csv|
      unless csv[11] == '/' || csv[11] == '/  /'
        csv[11] = csv[11].split(' ')[0]
        puts csv[11]
      end
    end
  end
end

