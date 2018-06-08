require 'spreadsheet'
require 'creek'

class OspParser
  attr_accessor :xls_hash, :xlsx_hash, :active_users

  def initialize(xlsx_obj = Creek::Book.new('data/dmresults.xlsx'), 
                 xls_obj = Spreadsheet.open('data/psu-users.xls'))
    @xlsx_hash = convert_xlsx_to_hash(xlsx_obj.sheets[0])
    @xls_hash = convert_xls_to_hash(xls_obj.worksheet(0))
    @active_users = find_active_users
  end

  #Run all local formatting methods
  def format
    xlsx_hash.each do |row|
      format_nils(row)
      format_accessid_field(row)
      format_role_field(row)
      format_date_fields(row)
      format_pending(row)
      format_start_end(row)
      remove_columns(row)
    end
  end

  def filter_by_date
    kept_rows = []
    xlsx_hash.each do |row|
      if (row['submitted'].split('-')[0].to_i >= 2011) && (row['submitted'].split('-')[0].to_i <= 2018) 
        kept_rows << row
      end
    end
    @xlsx_hash = kept_rows
  end

  def filter_by_user
    kept_rows = []
    xlsx_hash.each do |row|
      active_users.each do |user|
        if user[3] == row['accessid']
          row['m_name'] = user[2]
          row['l_name'] = user[0]
          row['f_name'] = user[1]
          kept_rows << row
        end
      end
    end
    @xlsx_hash = kept_rows
  end

  def filter_by_status
    kept_rows = []
    xlsx_hash.each do |row|
      unless (row['status'] == 'Purged') || (row['status'] == 'Withdrawn')
        kept_rows << row
      end
    end
    @xlsx_hash = kept_rows
  end

  def write_results_to_xl(filename = 'data/dmresults-formatted.xls') 
    wb = Spreadsheet::Workbook.new filename
    sheet = wb.create_worksheet
    xlsx_hash[0].each do |k, v|
      sheet.row(0).push(k)
    end
    xlsx_hash.each_with_index do |row, index|
      row.each do |k, v|
        sheet.row(index+1).push(v)
      end
    end
    wb.write filename 
  end

  private

  def convert_xlsx_to_hash(xlsx_sheet)
    counter = 0
    keys = []
    data = []
    data_hashed = []
    xlsx_sheet.rows.each do |row|
      values = []
      if counter == 0
        row.each {|k,v| keys << v}
      else
        row.each {|k,v| values << v}
        data << values
      end 
      counter += 1
    end
    data.each {|a| data_hashed << Hash[ keys.zip(a) ] }
    return data_hashed
  end

  def convert_xls_to_hash(xls_sheet)
    keys = xls_sheet.row(2)
    data_hashed = []
    xls_sheet.drop(2).each do |row|
      data_hashed << Hash[ keys.zip(row) ]
    end
    return data_hashed
  end

  def find_active_users
    active_user_arr = []
    xls_hash.each do |row|
      if row['Enabled?'].downcase == 'yes' && row['Has Access to Manage Activities?'].downcase == 'yes'
        active_user_arr << [row['Last Name'], row['First Name'], row['Middle Name'], row['Username'].downcase]
      end
    end
    active_user_arr
  end

  def format_nils(row)
    row.each do |k, v|
      if v  == nil
        row[k] = ''
      end
    end
  end

  def format_accessid_field(row)
    if row['accessid'].to_s.include? ', '
      unless row['accessid'].to_s.split(' ')[3] == '2018'
        row['accessid'] = row['accessid'].to_s.split(' ')[2].downcase + row['accessid'].to_s.split(' ')[3][2..3]
      else
        row['accessid'] = row['accessid'].to_s.split(' ')[2].downcase + row['accessid'].to_s.split(' ')[1].sub!(/^0+/, "")
      end
    end
  end

  def format_role_field(row)
    if row['role'] == 'Co-PI'
      row['role'] = 'Co-Principal Investigator'
    end
    if row['role'] == 'Faculty'
      row['role'] = 'Core Faculty'
    end
    if row['role'] == 'Post Doctoral'
      row['role'] = 'Post Doctoral Associate'
    end
    if row['role'] == 'unknown'
      row['role'] = 'Unknown'
    end
  end

  def format_date_fields(row)
    key_arr = ['submitted', 'awarded', 'startdate', 'enddate']
    key_arr.each do |k|
      if row[k] == '/' || row[k] == '/  /'
        row[k] = ''
      end
      begin
        date = DateTime.parse(row[k].to_s)
        row[k] = date.strftime("%Y-%m-%d").to_s
      rescue ArgumentError => e
        #puts e
      end
    end
  end

  def format_pending(row)
    if row['status'] == 'Pending Proposal' || row['status'] == 'Pending Award'
      row['status'] = 'Pending'
    end
  end

  def format_start_end(row)
    unless row['status'] == 'Awarded'
      row['startdate'] = ''
      row['enddate'] = ''
    end
  end

  def remove_columns(row)
    index_arr = ['ordernumber', 'parentsponsor', 'department', 'totalstartdate', 
                 'totalenddate', 'agreementtype', 'agreement']
    index_arr.each do |i|
      row[i] = nil
    end
    row.compact!
  end

end

