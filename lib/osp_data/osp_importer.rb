require 'creek'

class OspImporter
  attr_accessor :headers, :xlsx_obj, :pendnotfund

  def initialize(osp_path = 'data/dmresults.xlsx', backup_path = 'data/CONGRANT-tabdel.txt')
    @xlsx_obj = Creek::Book.new(osp_path).sheets[0].rows
    @headers = @xlsx_obj.first
    @pendnotfund = find_converts(backup_path)
  end

  #Run all local formatting methods then import to db
  def format_and_populate
    counter = 0
    xlsx_obj.each do |row|
      if counter == 0
        counter += 1
        next
      end
      row = convert_xlsx_row_to_hash(row)
      format_date_fields(row)
      format_accessid_field(row)
      next unless is_user(row)
      next unless is_good_date(row)
      next unless is_proper_status(row)
      format_nils(row)
      format_titles(row)
      format_role_field(row)
      format_pending(row)
      format_start_end(row)
      populate_db_with_row(row)
    end
  end

  private

  def is_good_date(row)
    if (row['submitted'].blank?) && (row['awarded'].present?)
      if (row['awarded'].split('-')[0].to_i >= 2011) && (row['awarded'].split('-')[0].to_i <= DateTime.now.year)
        return true
      end
    else
      if (row['submitted'].split('-')[0].to_i >= 2011) && (row['submitted'].split('-')[0].to_i <= DateTime.now.year)
        return true
      end
    end
    false
  end

  def is_user(row)
    user = Faculty.find_by(access_id: row['accessid'])
    return true if user.present?

    false
  end

  def is_proper_status(row)
    if row['status'] == 'Purged' || row['status'] == 'Withdrawn'
      if pendnotfund.include? row['ospkey']
        return true
      else
        return false
      end
    else
      true
    end
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

  def convert_xlsx_row_to_hash(row)
    keys = headers.values
    Hash[ keys.zip(row.values) ]
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

  def populate_db_with_row(row)
    sponsor = Sponsor.find_or_create_by(sponsor_name: row['sponsor']) do |attr|
                             attr.sponsor_type = row['sponsortype']
                             end

    contract = Contract.find_or_create_by(osp_key: row['ospkey']) do |attr|
                                          attr.title = row['title']
                                          attr.sponsor = sponsor
                                          attr.status = row['status']
                                          attr.submitted = row['submitted']
                                          attr.awarded = row['awarded']
                                          attr.requested = row['requested']
                                          attr.funded = row['funded']
                                          attr.total_anticipated = row['totalanticipated']
                                          attr.start_date = row['startdate']
                                          attr.end_date = row['enddate']
                                          attr.grant_contract = row['grantcontract']
                                          attr.base_agreement = row['baseagreement']
                                          attr.notfunded = row['notfunded']
                                          end

    faculty = Faculty.find_by(access_id: row['accessid'])

    begin
      ContractFacultyLink.create(contract:   contract,
                                 faculty:    faculty,
                                 role:       row['role'],
                                 pct_credit: row['pctcredit'])

    rescue ActiveRecord::RecordNotUnique
      return
    end
  end
end

