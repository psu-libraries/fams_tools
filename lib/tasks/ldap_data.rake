require 'ldap_data/import_ldap_data'

namespace :ldap_data do

  desc "Get personal contact information from ldap"

  task get_data: :environment do
    ImportLdapData.new.import_ldap_data
  end
end
