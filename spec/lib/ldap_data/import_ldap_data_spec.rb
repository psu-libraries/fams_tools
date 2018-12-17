require 'rails_helper'
require 'ldap_data/import_ldap_data'

RSpec.describe ImportLdapData do
  
  before do
    faculty1 = Faculty.create!(access_id: 'tstem31')
    faculty2 = Faculty.create!(access_id: 'ajk5603')
    PersonalContact.create!(faculty: faculty1, uid: 'tstem31')
  end

  describe '#call' do
    let(:importer) { ImportLdapData.new }

    it 'imports faculty data from ldap using faculty in our database' do
      expect{ importer.import_ldap_data }.to change { PersonalContact.count }.by 1

      pc1 = PersonalContact.find_by(uid: "ajk5603")
      pc2 = PersonalContact.find_by(uid: "tstem31")

      expect(pc1['postal_address']).to eq "W 313 Pattee Library$University Park, PA 16802 US"
      expect(pc1['telephone_number']).to eq nil
      expect(pc1['department']).to eq nil
      expect(pc1['title']).to eq "Programmer/Analyst 2"
      expect(pc1['ps_research']).to eq nil
      expect(pc1['ps_teaching']).to eq nil
      expect(pc1['ps_office_address']).to eq nil
      expect(pc1['facsimile_telephone_number']).to eq nil
      expect(pc1['mail']).to eq "ajk5603@psu.edu"
      expect(pc1['cn']).to eq "Alex Kiessling"
      expect(pc1['personal_web']).to eq nil

      expect(pc2['postal_address']).to eq nil
      expect(pc2['telephone_number']).to eq nil
      expect(pc2['department']).to eq nil
      expect(pc2['title']).to eq nil
      expect(pc2['ps_research']).to eq nil
      expect(pc2['ps_teaching']).to eq nil
      expect(pc2['ps_office_address']).to eq nil
      expect(pc2['facsimile_telephone_number']).to eq nil
      expect(pc2['mail']).to eq "tstem31@psu.edu"
      expect(pc2['cn']).to eq nil
      expect(pc1['personal_web']).to eq nil
    end
  end

end
