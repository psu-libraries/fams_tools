class OspData::OspImporter
  attr_accessor :headers, :csv_obj, :pendnotfund

  def initialize(osp_path = "#{Rails.root.join('app/parsing_files/contract_grants.csv')}",
                 backup_path = "#{Rails.root.join('app/parsing_files/CONGRANT.csv')}")
    @csv_obj = CSV.open(osp_path, encoding: 'Windows-1252:UTF-8', force_quotes: true, quote_char: '"')
    @headers = @csv_obj.first
    @pendnotfund = find_converts(backup_path)
  end

  # Run all local formatting methods then import to db
  def format_and_populate
    csv_obj.each do |row|
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
    if row['submitted'].blank? && row['awarded'].present?
      if (DateTime.strptime(row['awarded'],
                            '%m/%d/%Y %T').year >= 2011) && (DateTime.strptime(row['awarded'],
                                                                               '%m/%d/%Y %T').year <= DateTime.now.year)
        return true
      end
    elsif row['submitted'].present?
      if (DateTime.strptime(row['submitted'],
                            '%m/%d/%Y %T').year >= 2011) && (DateTime.strptime(row['submitted'],
                                                                               '%m/%d/%Y %T').year <= DateTime.now.year)
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

  def is_proper_status(row)   # We want to update Not Funded to purged or withdrawn but we dont want to import any new Not Funded, withdrawn, or purged contracts
    if %w[Purged Withdrawn].include?(row['status'])
      return true if pendnotfund.include? row['ospkey']

      false

    elsif ['Not Funded'].include?(row['status'])
      return false 

    else
      true
    end
  end

  def convert_csv_row_to_hash(row)
    headers.zip(row).to_h
  end

  def format_sponsor_type(row)
    return unless row['sponsortype'] == 'Associations, Institutes, Societies and Voluntary'

    row['sponsortype'] = 'Associations, Institutes, Societies and Voluntary Health Agencies'
  end

  def format_nils(row)
    row.each do |k, v|
      row[k] = '' if v.nil?
    end
  end

  def format_accessid_field(row)
    return unless row['accessid'].to_s.include? '00:00:00'

    if DateTime.strptime(row['accessid'], '%m/%d/%Y %T').year == (DateTime.now.year)
      row['accessid'] =
DateTime.strptime(row['accessid'],
                  '%m/%d/%Y %T').strftime('%b').downcase + DateTime.strptime(row['accessid'],
                                                                             '%m/%d/%Y %T').strftime('%-d')
    else
      row['accessid'] =
DateTime.strptime(row['accessid'],
                  '%m/%d/%Y %T').strftime('%b').downcase + DateTime.strptime(row['accessid'],
                                                                             '%m/%d/%Y %T').year.to_s[2..3]
    end
  end

  def format_role_field(row)
    row['role'] = 'Co-Principal Investigator' if row['role'] == 'Co-PI'
    row['role'] = 'Core Faculty' if row['role'] == 'Faculty'
    row['role'] = 'Post Doctoral Associate' if row['role'] == 'Post Doctoral'
    return unless row['role'] == 'unknown'

    row['role'] = 'Unknown'
  end

  def format_date_fields(row)
    key_arr = %w[submitted awarded startdate enddate notfunded]
    key_arr.each do |k|
      row[k] = '' if ['/', '/  /'].include?(row[k])
    end
  end

  def format_pending(row)
    return unless ['Pending Proposal', 'Pending Award'].include?(row['status'])

    row['status'] = 'Pending'
  end

  def format_start_end(row)
    return if row['status'] == 'Awarded'

    row['startdate'] = ''
    row['enddate'] = ''
  end

  def find_converts(backup_path)
    index = 0
    keys = []
    pendnotfund = []
    CSV.foreach(backup_path, encoding: 'ISO8859-1:UTF-8', force_quotes: true, quote_char: '"',
                             liberal_parsing: true) do |backup_row|
      if index == 0
        keys = backup_row
      else
        hashed = keys.zip(backup_row).to_h
        pendnotfund << hashed['OSPKEY'] if ['Pending', 'Not Funded'].include?(hashed['STATUS'])
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

    contract = Contract.find_or_initialize_by(osp_key: row['ospkey'])

    should_update_contract = contract.new_record? || (contract.status == 'Pending' && row['status'] == 'Awarded')

    if should_update_contract
      contract.title = row['title']
      contract.sponsor = sponsor
      contract.status = row['status']

      contract.submitted = (DateTime.strptime(row['submitted'], '%m/%d/%Y %T') if row['submitted'].present?)
      contract.awarded = (DateTime.strptime(row['awarded'], '%m/%d/%Y %T') if row['awarded'].present?)
      contract.requested = row['requested']
      contract.funded = row['funded']
      contract.total_anticipated = row['totalanticipated']
      contract.start_date = (DateTime.strptime(row['startdate'], '%m/%d/%Y %T') if row['startdate'].present?)
      contract.end_date = (DateTime.strptime(row['enddate'], '%m/%d/%Y %T') if row['enddate'].present?)
      contract.grant_contract = row['grantcontract']
      contract.base_agreement = row['baseagreement'].to_s.gsub("\u0000", '')
      contract.notfunded = (DateTime.strptime(row['notfunded'], '%m/%d/%Y %T') if row['notfunded'].present?)
      contract.effort_academic = row['effortacademic']
      contract.effort_summer = row['effortsummer']
      contract.effort_calendar = row['effortcalendar']
      contract.save!
    end

    faculty = Faculty.find_by(access_id: row['accessid'])

    begin
      ContractFacultyLink.create(contract: contract,
                                 faculty: faculty,
                                 role: row['role'],
                                 pct_credit: row['pctcredit'])
    rescue ActiveRecord::RecordNotUnique
      nil
    end
  end
end
