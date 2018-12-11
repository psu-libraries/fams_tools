require 'net/ldap'

class ImportLdapData
  attr_accessor :all_faculty

  def initialize(all_faculty = Faculty.all)
    @all_faculty = all_faculty
  end

  def import_ldap_data
    all_faculty.each do |faculty|
      ldap = Net::LDAP.new :host => 'test-dirapps.aset.psu.edu', :port => 389

      filter = Net::LDAP::Filter.eq( "uid", "#{faculty.access_id}" )
      treebase = "dc=psu,dc=edu"

      ldap.search( :base => treebase, :filter => filter ) do |entry|
        ldap_data_populate_db(entry)
      end
    end
  end

  private

  def ldap_data_populate_db(entry)
    ldap_data[:telephone_number] = entry['telephonenumber'].first
    ldap_data[:postal_address] = entry['postaladdress'].first
    ldap_data[:department] = entry['department'].first
    ldap_data[:title] = entry['title'].first
    ldap_data[:ps_research] = entry['psresearch'].first
    ldap_data[:ps_teaching] = entry['psteaching'].first
    ldap_data[:ps_office_address] = entry['ps_office_address'].first
    ldap_data[:facsimile_telephone_number] = entry['facsimiletelephonenumber'].first
    ldap_data[:mail] = entry['mail'].first
    ldap_data[:cn] = entry['cn'].first
  end

end

