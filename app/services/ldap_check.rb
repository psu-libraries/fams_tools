# frozen_string_literal: true

class LdapCheck
  def initialize(disable_client = AiDisableClient.new)
    @disable_client = disable_client
  end

  def check(data, should_disable)
    uids = extract_usernames(data)

    return { error: 'No usernames were found in uploaded CSV. Make sure there is a "Usernames" column.' } if uids.empty?

    entries = pull_ldap_data(uids)
    disabled_uids = find_disabled_users(entries)

    if should_disable
      uids_to_disable = entries
                        .filter { |entry| entry['eduPersonPrimaryAffiliation'].first == 'MEMBER' }
                        .map { |entry| entry['uid'].first }

      disabled_uids = disable_users(disabled_uids, uids_to_disable)
    end

    output = generate_output(entries, disabled_uids)

    { output: }
  end

  private

  def extract_usernames(data)
    CSV.parse(data.read, headers: true)
       .filter_map { |row| row['Username'] }
  end

  def find_disabled_users(entries)
    entries.filter_map do |entry|
      uid = entry['uid'].first
      data = @disable_client.user(uid)['User']
      uid if data['enabled'] == 'false'
    end
  end

  def disable_users(disabled_uids, uids)
    uids.each do |uid|
      next if disabled_uids.include?(uid)

      @disable_client.enable_user(uid, false)
      disabled_uids.append(uid)
    end

    disabled_uids
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

  def generate_output(entries, disabled_uids)
    headers = ['Username', 'Name', 'Primary Affiliation', 'Title', 'Department', 'Campus', 'Disabled?']

    CSV.generate do |csv|
      csv << headers

      entries.each do |entry|
        uid = entry['uid'].first
        csv << [
          uid,
          entry['displayName'].first,
          entry['eduPersonPrimaryAffiliation'].first,
          entry['title'].first,
          entry['psBusinessArea'].first,
          entry['psCampus'].first,
          disabled_uids.include?(uid) ? 'yes' : 'no'
        ]
      end
    end
  end
end
