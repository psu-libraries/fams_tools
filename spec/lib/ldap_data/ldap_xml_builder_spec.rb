require 'rails_helper'
require 'ldap_data/ldap_xml_builder'

RSpec.describe LdapXmlBuilder do

  before do
    create :personal_contact 
  end

  let(:ldap_xml_builder_obj) { LdapXmlBuilder.new }

  describe "#batched_ldap_xml" do
    it "should return an array of personal contact data xmls" do
      expect(ldap_xml_builder_obj.batched_xmls).to eq([
'<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="abc1">
    <PCI>
      <OPHONE1>123</OPHONE1>
      <OPHONE2>456</OPHONE2>
      <OPHONE3>7891</OPHONE3>
      <BUILDING> Test Office Address</BUILDING>
      <ROOMNUM>123</ROOMNUM>
      <RESEARCH_INTERESTS>Test research interests.</RESEARCH_INTERESTS>
      <TEACHING_INTERESTS>Test teaching interests.</TEACHING_INTERESTS>
      <FNAME>Test</FNAME>
      <MNAME>Person</MNAME>
      <LNAME>User</LNAME>
    </PCI>
  </Record>
</Data>
'
      ])
    end
  end

end