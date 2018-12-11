require 'net/ldap'

class ImportLdapData
  attr_accessor :all_faculty

  def initialize(all_faculty = Faculty.all)
    @all_faculty = all_faculty
  end

  def import
    all_faculty.each do |faculty|
      return get_ldap_data(faculty)
    end
  end

  private

  def get_ldap_data(faculty)
    ldap_data = {}
    ldap = Net::LDAP.new :host => 'test-dirapps.aset.psu.edu', :port => 389

    filter = Net::LDAP::Filter.eq( "uid", "#{faculty.access_id}" )
    treebase = "dc=psu,dc=edu"

    ldap.search( :base => treebase, :filter => filter ) do |entry|
      ldap_data[:telephone_number] = entry['telephonenumber'].first
      ldap_data[:postal_address] = entry['postaladdress'].first
      ldap_data[:department] = entry['department'].first
      ldap_data[:title] = entry['title'].first
    end

    ldap_data
  end
end

