require 'ldap_data/get_ldap_data'

namespace :ldap_data do

  desc "Get personal contact informanction from ldap"

  task get_data: :environment do
    GetLdapData.new.call
  end
end
