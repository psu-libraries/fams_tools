class LdapCheckJob < ApplicationJob
  def integrate(params, _user_uploaded = true)
    ldap_conn = connect_to_central_ldap

    f_name = params[:ldap_check_file].original_filename
    f_path = File.join('app', 'parsing_files', 'check.csv')
    File.binwrite(f_path, params[:ldap_check_file].read)

    uids = CSV.read(f_path, headers: true).map { |row| row['Username'] }
    data = pull_ldap_data(ldap_conn, uids)
    
    headers = ['Username', 'Primary Affiliation']
    
    CSV.open('check_output.csv', 'wb') do |csv|
      csv << headers
      
      data.each do |entry|
        csv << [
          entry['uid'].first,
          entry['eduPersonPrimaryAffiliation'].first
        ]
      end
    end

    File.delete(f_path) if File.exist?(f_path)
    nil
  end

  private
  def pull_ldap_data(conn, uids)
    joined_filter = uids.map { |uid| Net::LDAP::Filter.eq("uid", uid) }.reduce(:|)

    conn.search(
      base: 'dc=psu,dc=edu',
      filter: joined_filter
    )
  end

  def connect_to_central_ldap
    Net::LDAP.new(
      host: ENV.fetch('CENTRAL_LDAP_HOST', 'test-dirapps.aset.psu.edu'),
      port: ENV.fetch('CENTRAL_LDAP_PORT', '389')
    )
  end

  def name
    'LDAP Check'
  end
end
