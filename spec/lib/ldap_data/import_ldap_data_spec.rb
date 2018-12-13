require 'rails_helper'
require 'ldap_data/import_ldap_data'

RSpec.describe ImportLdapData do
  
  before do
    Faculty.create!(access_id: 'ajk5603')
  end

  describe '#call' do
    let(:importer) { ImportLdapData.new }

    it 'imports faculty data from ldap using faculty in our database' do
      expect{ importer.import_ldap_data }.to change { PersonalContact.count }.by 1
    end
  end

end
