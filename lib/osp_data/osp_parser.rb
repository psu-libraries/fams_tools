require 'creek'

class OspParser
  attr_accessor :xlsx_hash, :active_users, :xlsx_obj, :pendnotfund

  def initialize(osp_path = 'data/dmresults.xlsx', backup_path = 'data/CONGRANT-tabdel.txt')
    @xlsx_obj = Creek::Book.new(osp_path).sheets[0].rows
    @xlsx_hash = convert_xlsx_to_hash(xlsx_obj)
    @active_users = Faculty.pluck(:access_id)
    @pendnotfund = find_converts(backup_path)
  end

  #Run all local formatting methods
  def format
    xlsx_hash.each do |row|
      format_nils(row)
      format_titles(row)
      format_accessid_field(row)
      format_role_field(row)
      format_date_fields(row)
      format_pending(row)
      format_start_end(row)
    end
  end

  def filter_by_date
    kept_rows = []
    xlsx_hash.each do |row|
      if (row['submitted'].empty?) && (row['awarded'].present?)
        if (row['awarded'].split('-')[0].to_i >= 2011) && (row['awarded'].split('-')[0].to_i <= DateTime.now.year)
          kept_rows << row
        end
      else
        if (row['submitted'].split('-')[0].to_i >= 2011) && (row['submitted'].split('-')[0].to_i <= DateTime.now.year)
          kept_rows << row
        end
      end
    end
    @xlsx_hash = kept_rows
  end

  def filter_by_user
    kept_rows = []
    xlsx_hash.each do |row|
      if active_users.include? row['accessid']
        kept_rows << row
      end
    end
    @xlsx_hash = kept_rows
  end

  def filter_by_status
    index = 0
    keys = []
    kept_rows = []
    xlsx_hash.each do |row|
      if row['status'] == 'Purged' || row['status'] == 'Withdrawn'
        if pendnotfund.include? row['ospkey']
          kept_rows << row
        end
      else
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

  def csv_to_hashes(congrant_data)
    keys = congrant_data[0]
    congrant_data[1..-1].map {|a| Hash[ keys.zip(a) ] }
  end

  def convert_xlsx_to_hash(xlsx_sheet)
    counter = 0
    keys = []
    data = []
    data_hashed = []
    xlsx_sheet.each do |row|
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

  def format_nils(row)
    row.each do |k, v|
      if v  == nil
        row[k] = ''
      end
    end
  end

  def format_accessid_field(row)
    if row['accessid'].to_s.include? ', '
      unless (row['accessid'].to_s.split(' ')[3]) == (DateTime.now.year.to_s)
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
    key_arr = ['submitted', 'awarded', 'startdate', 'enddate', 'notfunded']
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

  def find_converts(backup_path)
    index = 0
    keys = []
    pendnotfund = []
    CSV.foreach(backup_path, encoding: "ISO8859-1", col_sep: "\t") do |backup_row|
      if index == 0
        keys = backup_row
      else
        hashed = Hash[ keys.zip(backup_row) ]
        if hashed['STATUS'] == 'Pending' || hashed['STATUS'] == 'Not Funded'
          pendnotfund << hashed['OSPKEY']
        end
      end
      index += 1
    end
    pendnotfund
  end

  def format_titles(row)
    row['title'].gsub! '&quot;', '"'
    row['title'].gsub! '&#39;', "'"
  end
end

