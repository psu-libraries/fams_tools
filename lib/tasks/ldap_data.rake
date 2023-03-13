namespace :ldap_data do

  desc "Get personal contact information from ldap"

  task get_data: :environment do
    start = Time.now
    LdapData::ImportLdapData.new.import_ldap_data
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins') 
  end

  desc "Integrate data into AI through WebServices."

  task integrate: :environment do
    start = Time.now
    my_integrate = ActivityInsight::IntegrateData.new(LdapData::LdapXmlBuilder.new, :beta)
    my_integrate.integrate
    finish = Time.now
    puts(((finish - start)/60).to_s + ' mins') 
  end

end
