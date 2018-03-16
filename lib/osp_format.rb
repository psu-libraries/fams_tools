require 'spreadsheet'
require 'csv'

class OspFormat

  #Creates CSV and XLS object.  Imported CSV must be tab delimited text.
  def initialize(csv_object = CSV.read('data/dmresults-tabdel.txt', encoding: "ISO8859-1", col_sep: "\t"), 
                 xls_object = Spreadsheet.open('data/ai-user-accounts.xls'))
    @csv_object = csv_object
    @xls_object = xls_object.worksheet 0
    @active_users = find_active_users
  end

  def csv_object
    @csv_object
  end

  def xls_object
    @xls_object
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
    index_arr = [11, 12, 16, 17]
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
        kept_rows.push(csv)
      end
    end
    @csv_object = kept_rows
  end

  #Remove columns we don't need
  def remove_columns
    index_arr = [1, 5, 7, 18, 19, 22, 23]
    self.csv_object.each do |csv|
      index_arr.each do |i|
        csv[i] = nil
      end
      csv.compact!
    end
  end

  #Remove rows that contain non-active users
  def filter_by_user
    kept_rows = []
    self.csv_object.each do |csv|
      if @active_users.include? csv[4]
        kept_rows << csv
      end
    end
    @csv_object = kept_rows
  end

  private
  #Creates a list of 'Enabled' AI users
  def find_active_users
    active_user_arr = []
    self.xls_object.each do |xls|
      if xls[6].downcase == 'yes'
        active_user_arr << xls[4].downcase
      end
    end
    active_user_arr
  end
end

