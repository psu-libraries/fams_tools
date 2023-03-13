require 'creek'

class OspData::OspImporter
  attr_accessor :headers, :csv_obj, :pendnotfund

  def initialize(osp_path = "#{Rails.root}/app/parsing_files/contract_grants.csv", backup_path = "#{Rails.root}/app/parsing_files/CONGRANT.csv")
    @csv_obj = CSV.open(osp_path, encoding: "Windows-1252:UTF-8", force_quotes: true, quote_char: '"')
    @headers = @csv_obj.first
    @pendnotfund = find_converts(backup_path)
  end

  #Run all local formatting methods then import to db
  def format_and_populate
    csv_obj.each_with_index do |row|
      row = convert_csv_row_to_hash(row)
      format_date_fields(row)
      format_accessid_field(row)
      next unless is_user(row)
      next unless is_good_date(row)
      next unless is_proper_status(row)
      format_sponsor_type(row)
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
      if (DateTime.strptime(row['awarded'], '%m/%d/%Y %T').year >= 2011) && (DateTime.strptime(row['awarded'], '%m/%d/%Y %T').year <= DateTime.now.year)
        return true
      end
    elsif row['submitted'].present?
      if (DateTime.strptime(row['submitted'], '%m/%d/%Y %T').year >= 2011) && (DateTime.strptime(row['submitted'], '%m/%d/%Y %T').year <= DateTime.now.year)
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

  def convert_csv_row_to_hash(row)
    Hash[ headers.zip(row) ]
  end

  def format_sponsor_type(row)
    if row['sponsortype'] == 'Associations, Institutes, Societies and Voluntary'
      row['sponsortype'] = 'Associations, Institutes, Societies and Voluntary Health Agencies'
    end
  end

  def format_nils(row)
    row.each do |k, v|
      if v  == nil
        row[k] = ''
      end
    end
  end

  def format_accessid_field(row)
    if row['accessid'].to_s.include? '00:00:00'
      unless DateTime.strptime(row['accessid'], '%m/%d/%Y %T').year == (DateTime.now.year)
        row['accessid'] = DateTime.strptime(row['accessid'], '%m/%d/%Y %T').strftime('%b').downcase + DateTime.strptime(row['accessid'], '%m/%d/%Y %T').year.to_s[2..3]
      else
        row['accessid'] = DateTime.strptime(row['accessid'], '%m/%d/%Y %T').strftime('%b').downcase + DateTime.strptime(row['accessid'], '%m/%d/%Y %T').strftime('%-d')
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
    CSV.foreach(backup_path, encoding: "ISO8859-1:UTF-8", force_quotes: true, quote_char: '"', liberal_parsing: true) do |backup_row|
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
                                          attr.submitted = DateTime.strptime(row['submitted'], '%m/%d/%Y %T') if row['submitted'].present?
                                          attr.awarded = DateTime.strptime(row['awarded'], '%m/%d/%Y %T') if row['awarded'].present?
                                          attr.requested = row['requested']
                                          attr.funded = row['funded']
                                          attr.total_anticipated = row['totalanticipated']
                                          attr.start_date = DateTime.strptime(row['startdate'], '%m/%d/%Y %T') if row['startdate'].present?
                                          attr.end_date = DateTime.strptime(row['enddate'], '%m/%d/%Y %T') if row['enddate'].present?
                                          attr.grant_contract = row['grantcontract']
                                          attr.base_agreement = row['baseagreement']
                                          attr.notfunded = DateTime.strptime(row['notfunded'], '%m/%d/%Y %T') if row['notfunded'].present?
                                          attr.effort_academic = row['effortacademic']
                                          attr.effort_summer = row['effortsummer']
                                          attr.effort_calendar = row['effortcalendar']
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

