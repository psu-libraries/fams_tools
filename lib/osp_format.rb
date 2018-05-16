require 'spreadsheet'
require 'csv'
require 'roo'

class OspFormat
  attr_accessor :csv_object, :xls_object, :csv_hash

  #Creates CSV and XLS object.  Imported CSV must be tab delimited text.
  def initialize(csv_array = Roo::Spreadsheet.open('data/dmresults.xlsx').sheet(0), 
                 xls_object = Spreadsheet.open('data/psu-users.xls'))
    @csv_hash = convert_to_hash(csv_array)
    @xls_object = xls_object.worksheet 0
    @active_users = find_active_users
  end

  #Run all local formatting methods
  def format
    csv_hash.each do |csv|
      format_nils(csv)
      format_accessid_field(csv)
      format_role_field(csv)
      format_date_fields(csv)
      format_pending(csv)
      format_start_end(csv)
      remove_columns(csv)
    end
  end

  #Remove rows with 'submitted' dates <= 2011
  def filter_by_date
    kept_rows = []
    csv_hash.each do |csv|
      if (csv['submitted'].split('-')[0].to_i >= 2011) && (csv['submitted'].split('-')[0].to_i <= 2018) 
        kept_rows << csv
      end
    end
    @csv_hash = kept_rows
  end

  #Remove rows that contain non-active users
  def filter_by_user
    kept_rows = []
    csv_hash.each do |csv|
      @active_users.each do |user|
        if user[3] == csv['accessid']
          csv['m_name'] = user[2]
          csv['l_name'] = user[0]
          csv['f_name'] = user[1]
          kept_rows << csv
        end
      end
    end
    @csv_hash = kept_rows
  end

  #Remove rows with 'Purged' or 'Withdrawn' status
  def filter_by_status
    kept_rows = []
    csv_hash.each do |csv|
      unless (csv['status'] == 'Purged') || (csv['status'] == 'Withdrawn')
        kept_rows << csv
      end
    end
    @csv_hash = kept_rows
  end

  #Write the cleaned and filtered array to xl file
  def write_results_to_xl(filename = 'data/dmresults-formatted.xls') 
    wb = Spreadsheet::Workbook.new filename
    sheet = wb.create_worksheet
    csv_hash[0].each do |k, v|
      sheet.row(0).push(k)
    end
    csv_hash.each_with_index do |row, index|
      row.each do |k, v|
        sheet.row(index+1).push(v)
      end
    end
    wb.write filename 
  end

  private

  #Convert csv array to a hash
  def convert_to_hash(csv_array)
    csv_hash = []
    keys = csv_array.row(1)
    csv_array.each {|a| csv_hash << Hash[ keys.zip(a) ] }
    csv_hash
  end

  #Creates a list of 'Enabled' and 'Has Access' AI users
  def find_active_users
    active_user_arr = []
    xls_object.drop(3).each do |xls|
      if xls[6].downcase == 'yes' && xls[7].downcase == 'yes'
        active_user_arr << [xls[0], xls[1], xls[2], xls[4].downcase]
      end
    end
    active_user_arr
  end

  #Replace nil with empty space
  def format_nils(csv)
    csv.each do |k, v|
      if v  == nil
        csv[k] = ''
      end
    end
  end

  #Converts calendar dates back to accessids
  def format_accessid_field(csv)
    if csv['accessid'].to_s.include? ', '
      unless csv['accessid'].to_s.split(' ')[2][0] =~ /[A-Z]/
        csv['accessid'] = csv['accessid'].to_s.split(' ')[1..2].reverse.join("").downcase
      else
        csv['accessid'] = csv['accessid'].to_s.split(' ')[1..2].join("").downcase
      end
    end
  end

  #Converts 'Co-PI' to 'Co-Principal Investigator', 'Faculty' to 'Core Faculty', 
  #'Post Doctoral' to 'Post Doctoral Associate', and 'unknown' to 'Unknown'
  def format_role_field(csv)
    if csv['role'] == 'Co-PI'
      csv['role'] = 'Co-Principal Investigator'
    end
    if csv['role'] == 'Faculty'
      csv['role'] = 'Core Faculty'
    end
    if csv['role'] == 'Post Doctoral'
      csv['role'] = 'Post Doctoral Associate'
    end
    if csv['role'] == 'unknown'
      csv['role'] = 'Unknown'
    end
  end

  #Removes time, '/', and '/ /' from date fields.  Convert mm/dd/yy to Date object 
  def format_date_fields(csv)
    key_arr = ['submitted', 'awarded', 'startdate', 'enddate']
    key_arr.each do |k|
      if csv[k] == '/' || csv[k] == '/  /'
        csv[k] = ''
      end
      begin
        date = DateTime.parse(csv[k].to_s)
        csv[k] = date.strftime("%Y-%m-%d").to_s
      rescue ArgumentError => e
        #puts e
      end
    end
  end

  #Changes 'Pending Award' and 'Pending Proposal' status to 'Pending'
  def format_pending(csv)
    if csv['status'] == 'Pending Proposal' || csv['status'] == 'Pending Award'
      csv['status'] = 'Pending'
    end
  end

  #Removes start and end dates for any contract that was not 'Awarded'
  def format_start_end(csv)
    unless csv['status'] == 'Awarded'
      csv['startdate'] = ''
      csv['enddate'] = ''
    end
  end

  #Remove columns we don't need
  def remove_columns(csv)
    index_arr = ['ordernumber', 'parentsponsor', 'department', 'totalstartdate', 
                 'totalenddate', 'agreementtype', 'agreement']
    index_arr.each do |i|
      csv[i] = nil
    end
    csv.compact!
  end

end

