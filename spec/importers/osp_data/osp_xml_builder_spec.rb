require 'importers/importers_helper'

RSpec.describe OspXMLBuilder do

  let!(:faculty1) { FactoryBot.create(:faculty, access_id: 'aaa111', user_id: 123) }
  let!(:faculty2) { FactoryBot.create(:faculty, access_id: 'ddd111', user_id: 234) }
  let!(:faculty3) { FactoryBot.create(:faculty, access_id: 'bbb222', user_id: 321) }
  let!(:contract1) { FactoryBot.create(:contract, osp_key: 12345, base_agreement: 'XYZ123') }
  let!(:contract2) { FactoryBot.create(:contract, osp_key: 12346, base_agreement: 'XYZ123') }
  let!(:contract3) { FactoryBot.create(:contract, osp_key: 12347, base_agreement: 'XYZ123') }
  let!(:contract4) { FactoryBot.create(:contract, osp_key: 12348, base_agreement: 'XYZ125') }
  let!(:link1) { FactoryBot.create(:contract_faculty_link, faculty: faculty1, contract: contract1)}
  let!(:link2) { FactoryBot.create(:contract_faculty_link, faculty: faculty1, contract: contract2)}
  let!(:link3) { FactoryBot.create(:contract_faculty_link, faculty: faculty1, contract: contract3)}
  let!(:link4) { FactoryBot.create(:contract_faculty_link, faculty: faculty2, contract: contract4)}
  let!(:link5) { FactoryBot.create(:contract_faculty_link, faculty: faculty1, contract: contract4)}

  let(:xml_builder_obj) {described_class.new}
  let(:final_xml_output) { File.read(Rails.root.join('spec', 'fixtures', 'contract_grant_xml_build.xml')) }

  describe '#batched_osp_xml' do
    it 'should return an xml of CONGRANT records' do
      expect(xml_builder_obj.xmls_enumerator.first).to eq(final_xml_output)
    end
  end
end

