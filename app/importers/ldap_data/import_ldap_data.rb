require 'net/ldap'

class LdapData::ImportLdapData
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
        ldap_data_populate_db(entry, faculty)
      end
    end
  end

  private

  def ldap_data_populate_db(entry, faculty)
    pc = PersonalContact.find_by(faculty: faculty) ||
         PersonalContact.new({faculty: faculty}.merge!(personal_contact_attrs(entry)))

    if pc.persisted?
      pc.update!(personal_contact_attrs(entry))
    else
      pc.save!
    end
  end

  def personal_contact_attrs(entry)
    {
    uid: entry['uid'].first,
    telephone_number: entry['telephonenumber'].first,
    postal_address: entry['postaladdress'].first,
    department: entry['department'].first,
    title: entry['title'].first,
    ps_research: entry['psresearch'].first,
    ps_teaching: entry['psteaching'].first,
    ps_office_address: entry['psofficeaddress'].first,
    facsimile_telephone_number: entry['facsimiletelephonenumber'].first,
    mail: entry['mail'].first,
    cn: entry['cn'].first,
    personal_web: entry['labeleduri'].first
      }
  end
end

