require 'importers/importers_helper'

RSpec.describe LdapData::LdapXmlBuilder do

  let!(:personal_contact) { FactoryBot.create :personal_contact }
  let(:xml_builder_obj) { LdapData::LdapXmlBuilder.new }

  describe "#batched_ldap_xml" do
    it "should return an array of personal contact data xmls" do
      expect(xml_builder_obj.xmls_enumerator.first).to eq(
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Data>
  <Record username=\"#{personal_contact.faculty.access_id}\">
    <PCI>
      <OPHONE1>123</OPHONE1>
      <OPHONE2>456</OPHONE2>
      <OPHONE3>7891</OPHONE3>
      <BUILDING>Test Office Address</BUILDING>
      <ROOMNUM>123</ROOMNUM>
      <RESEARCH_INTERESTS>Test research interests.</RESEARCH_INTERESTS>
      <TEACHING_INTERESTS>Test teaching interests.</TEACHING_INTERESTS>
      <EMAIL>abc123@psu.edu</EMAIL>
      <WEBSITE>www.personal.website</WEBSITE>
      <FNAME>Test</FNAME>
      <MNAME>Person</MNAME>
      <LNAME>User</LNAME>
    </PCI>
  </Record>
</Data>
"
      )
    end
  end

end
