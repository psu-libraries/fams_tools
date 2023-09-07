require 'importers/importers_helper'

RSpec.describe LdapData::ImportLdapData, ldap: true do
  before do
    faculty2 = Faculty.create!(access_id: 'ajk5603')
  end

  describe '#call' do
    let(:importer) { LdapData::ImportLdapData.new }

    it 'imports faculty data from ldap using faculty in our database' do
      expect { importer.import_ldap_data }.to change { PersonalContact.count }.by 1

      pc1 = PersonalContact.find_by(uid: 'ajk5603')

      expect(pc1['postal_address']).to eq '1 Paterno Library$University Park, PA 16802 US'
      expect(pc1['department']).to eq nil
      expect(pc1['title']).to eq 'Programmer/Analyst 4'
      expect(pc1['ps_research']).to eq nil
      expect(pc1['ps_teaching']).to eq nil
      expect(pc1['ps_office_address']).to eq nil
      expect(pc1['facsimile_telephone_number']).to eq nil
      expect(pc1['mail']).to eq 'ajk5603@psu.edu'
      expect(pc1['cn']).to eq 'Alex Kiessling'
      expect(pc1['personal_web']).to eq nil
    end
  end
end
