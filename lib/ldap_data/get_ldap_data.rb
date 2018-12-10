require 'net/ldap'

class GetLdapData

  def call
    ldap = Net::LDAP.new :host => 'test-dirapps.aset.psu.edu', :port => 389

    filter = Net::LDAP::Filter.eq( "uid", "ajk5603" )
    treebase = "dc=psu,dc=edu"

    ldap.search( :base => treebase, :filter => filter ) do |entry|
      puts "DN: #{entry.dn}"
      entry.each do |attribute, values|
        puts "   #{attribute}:"
        values.each do |value|
          puts "      --->#{value}"
        end
      end
    end

    p ldap.get_operation_result
  end
end

