require 'rails_helper'
require 'ldap_data/ldap_xml_builder'

RSpec.describe LdapXmlBuilder do

  before do
    create :personal_contact 
  end

  let(:ldap_xml_builder_obj) { LdapXmlBuilder.new }

  describe "#batched_ldap_xml" do
    it "should return an array of personal contact data xmls" do
      expect(ldap_xml_builder_obj.batched_xmls).to eq([])
    end
  end

end
