class LdapCheckController < ApplicationController
  def index
  end

  def create
    ldap = connect_to_central_ldap

    uids = extract_uids(params[:ldap_check_file])

    if uids.length == 0
      flash[:error] = 'No usernames where found in uploaded CSV. Make sure you have a "Usernames" column.'
      redirect_to ldap_check_path and return
    end

    entries = pull_ldap_data(ldap, uids)
    output = generate_output(entries)

    send_data(
      output,
      filename: 'ldap_check_results.csv',
      type: 'text/csv',
      disposition: 'attachment'
    )
  end

  private

  def connect_to_central_ldap
    Net::LDAP.new(
      host: ENV.fetch('CENTRAL_LDAP_HOST', 'test-dirapps.aset.psu.edu'),
      port: ENV.fetch('CENTRAL_LDAP_PORT', '389')
    )
  end

  def extract_uids(file)
    CSV.parse(file.read, headers: true)
      .filter_map { |row| row['Username'] }
      
  end
  
  def pull_ldap_data(conn, uids)
    joined_filter = uids.map { |uid| Net::LDAP::Filter.eq("uid", uid) }.reduce(:|)

    conn.search(
      base: 'dc=psu,dc=edu',
      filter: joined_filter
    )
  end

  def generate_output(entries)
    headers = ['Username', 'Name', 'Primary Affiliation', 'Title', 'Department', 'Campus']
    
    CSV.generate do |csv|
      csv << headers
      
      entries.each do |entry|
        csv << [
          entry['uid'].first,
          entry['displayName'].first,
          entry['eduPersonPrimaryAffiliation'].first,
          entry['title'].first,
          entry['psBusinessArea'].first,
          entry['psCampus'].first
        ]
      end
    end
  end
end
