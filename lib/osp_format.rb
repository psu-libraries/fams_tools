require 'spreadsheet'
require 'csv'

class OspFormat

  #Creates CSV and XLS object.  Imported CSV must be tab delimited text.
  def initialize(csv_object = CSV.read('data/dmresults-tabdel.txt', encoding: "ISO8859-1", col_sep: "\t"), 
                 xls_object = Spreadsheet.open('data/psu-users.xls'))
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

  #Replace nil with empty space
  def format_grant_contract
    @csv_object.each do |csv|
      if csv[20] == nil
        csv[20] = ''
      end
    end
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

  #Converts 'Co-PI' to 'Co-Principal Investigator'
  def format_role_field
    @csv_object.each do |csv|
      if csv[8] == 'Co-PI'
        csv[8] = 'Co-Principal Investigator'
      end
      if csv[8] == 'Faculty'
        csv[8] = 'Core Faculty'
      end
      if csv[8] == 'Post Doctoral'
        csv[8] = 'Post Doctoral Associate'
      end
      if csv[8] == 'unknown'
        csv[8] = 'Unknown'
      end
    end
  end

  #Removes time, '/', and '/ /' from date fields.  Convert mm/dd/yy to Date object 
  def format_date_fields
    index_arr = [11, 12, 16, 17]
    self.csv_object.each do |csv|
      index_arr.each do |i|
        unless csv[i] == '/' || csv[i] == '/  /'
          csv[i] = csv[i].split(' ')[0]
        else
          csv[i] = ''
        end
        begin
          date = Date.strptime(csv[i], "%m/%d/%y")
          csv[i] = date.strftime("%Y-%m-%d")
        rescue ArgumentError => e
          #puts e
        end
      end
    end
  end

  #Changes 'Pending Award' and 'Pending Proposal' status to 'Pending'
  def format_pending
    self.csv_object.each do |csv|
      if csv[10] == 'Pending Proposal' || csv[10] == 'Pending Award'
        csv[10] = 'Pending'
      end
    end
  end

  #Removes start and end dates for any contract that was not 'Awarded'
  def format_start_end
    self.csv_object.each do |csv|
      unless csv[10] == 'Awarded'
        csv[16] = ''
        csv[17] = ''
      end
    end
  end

  #Remove rows with 'submitted' dates <= 2011
  def filter_by_date
    kept_rows = []
    self.csv_object.each do |csv|
      if (csv[11].split('-')[0].to_i >= 2011) && (csv[11].split('-')[0].to_i <= 2035) 
        kept_rows << csv
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
      @active_users.each do |user|
        if user[3] == csv[4]
          csv = csv.insert(5, user[2])
          csv = csv.insert(5, user[0])
          csv = csv.insert(5, user[1])
          kept_rows << csv
        end
      end
    end
    @csv_object = kept_rows
  end

  #Remove rows with 'Purged' or 'Withdrawn' status
  def filter_purged_withdrawn
    kept_rows = []
    self.csv_object.each do |csv|
      if (csv[10] == 'Purged') || (csv[10] == 'Withdrawn')
        kept_rows << csv
      end
      @csv_object = kept_rows
    end
  end

  #Write the cleaned and filtered array to xl file
  def write_results_to_xl(filename = 'data/dmresults-formatted.xls')
    
    wb = Spreadsheet::Workbook.new filename
    sheet = wb.create_worksheet
    head_arr = ['ospkey', 'title', 'sponsor', 'sponsortype', 'accessid', 'f_name', 'l_name',
                'm_name', 'role', 'pctcredit','status', 'submitted', 'awarded', 'requested',
                'funded', 'totalanticipated', 'startdate', 'enddate', 'grantcontract', 'baseagreement',]

    head_arr.each do |head|
      sheet.row(0).push(head)
    end

    @csv_object.each_with_index do |row, index|
      row.each do |v|
        sheet.row(index+1).push(v)
      end
    end

    wb.write filename 
  end

  private
  #Creates a list of 'Enabled' and 'Has Access' AI users
  def find_active_users
    active_user_arr = []
    self.xls_object.drop(3).each do |xls|
      if xls[6].downcase == 'yes' && xls[7].downcase == 'yes'
        active_user_arr << [xls[0], xls[1], xls[2], xls[4].downcase]
      end
    end
    active_user_arr
  end
end

