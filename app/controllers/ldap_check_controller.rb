class LdapCheckController < ApplicationController
  def index; end

  def create
    should_disable = params['ldap_should_disable'] == '1'

    uids = extract_usernames(params[:ldap_check_file])

    return flash_error('No usernames were found in uploaded CSV. Make sure there is a "Usernames" column.') if uids.empty?

    entries = pull_ldap_data(uids)

    if should_disable
      uids_to_disable = entries
                        .filter { |entry| entry['eduPersonPrimaryAffiliation'].first == 'MEMBER' }
                        .map { |entry| entry['uid'].first }

      disabled_uids = disable_ai_users(uids_to_disable)
      output = generate_output(entries, disabled_uids)
    else
      output = generate_output(entries)
    end

    send_data(
      output,
      filename: 'ldap_check_results.csv',
      type: 'text/csv',
      disposition: 'attachment'
    )
  end

  private

  def flash_error(msg)
    flash[:error] = msg
    redirect_to ldap_check_path
  end

  def extract_usernames(file)
    CSV.parse(file.read, headers: true)
       .filter_map { |row| row['Username'] }
  end

  def disable_ai_users(uids)
    client = AiDisableClient.new

    uids.each do |uid|
      client.enable_user(uid, false)
    end

    uids
  end

  def pull_ldap_data(uids)
    conn = Net::LDAP.new(
      host: ENV.fetch('CENTRAL_LDAP_HOST', 'test-dirapps.aset.psu.edu'),
      port: ENV.fetch('CENTRAL_LDAP_PORT', '389')
    )

    joined_filter = uids.map { |uid| Net::LDAP::Filter.eq('uid', uid) }.reduce(:|)

    conn.search(
      base: 'dc=psu,dc=edu',
      filter: joined_filter
    )
  end

  def generate_output(entries, disabled_uids = nil)
    headers = ['Username', 'Name', 'Primary Affiliation', 'Title', 'Department', 'Campus']
    headers.append('Disabled?') if disabled_uids.present?

    CSV.generate do |csv|
      csv << headers

      entries.each do |entry|
        uid = entry['uid'].first
        row = [
          uid,
          entry['displayName'].first,
          entry['eduPersonPrimaryAffiliation'].first,
          entry['title'].first,
          entry['psBusinessArea'].first,
          entry['psCampus'].first
        ]
        row.append(disabled_uids.include?(uid) ? 'yes' : 'no') if disabled_uids.present?

        csv << row
      end
    end
  end
end
