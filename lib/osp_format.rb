require 'spreadsheet'
require 'csv'

class OspFormat
  #attr_accessor :csv_object

  #Creates CSV object.  Imported CSV must be tab delimited text.
  def initialize(csv_object = CSV.read('data/dmresults-tabdel.txt', encoding: "ISO8859-1", col_sep: "\t"))
    @csv_object = csv_object
  end

  def csv_object
    @csv_object
  end

  #Converts calendar dates back to accessids
  def format_accessid_field
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

  #Removes time, '/', and '/ /' from date fields
  def format_date_fields
    index_arr = [11, 12, 16, 17, 18, 19]
    self.csv_object.each do |csv|
      index_arr.each do |i|
        unless csv[i] == '/' || csv[i] == '/  /'
          csv[i] = csv[i].split(' ')[0]
        else
          csv[i] = ''
        end
      end
    end
  end

  #Remove rows with 'submitted' dates <= 2011
  def filter_by_date
    kept_rows = []
    self.csv_object.each do |csv|
      if (csv[11].split('/')[2].to_i >= 11) && (csv[11].split('/')[2].to_i <= 35) 
        @csv_object = kept_rows.push(csv)
      end
    end
  end

  #Remove columns we don't need
  def remove_columns

  end
end

