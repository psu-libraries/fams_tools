require 'rails_helper'
require 'pure_data/get_pure_ids'

RSpec.describe GetPureIDs do
  
  before(:each) do
    Faculty.create(access_id: 'xyz321',
                   user_id:   '54321',
                   f_name:    'Kyle',
                   l_name:    'Hamburger',
                   m_name:    'Charred')
    Faculty.create(access_id: 'abc123',
                   user_id:   '98765',
                   f_name:    'Dorothy',
                   l_name:    'Glycerine',
                   m_name:    'Orange')
    Faculty.create(access_id: 'zzz999',
                   user_id:   '76584',
                   f_name:    'Yolanda',
                   l_name:    'Nigel',
                   m_name:    'Table')
  end

  let(:get_pure_ids_obj) {GetPureIDs.new}

  describe '#call' do
    it 'should obtain Pure IDs for AI users' do
      stub_request(:get, Regexp.new('https://pennstate.pure.elsevier.com/ws/api/511/persons')).
        to_return(status: 200, body: 
'<result xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://pennstate.pure.elsevier.com/ws/api/511/xsd/schema1.xsd">
  <count>2</count>
  <navigationLink ref="next" href="https://pennstate.pure.elsevier.com/ws/api/511/persons?pageSize=1000&amp;offset=1000"/>
  <person uuid="" pureId="123" externalId="abc123" externalIdSource="synchronisedPerson" externallyManaged="true">
    <name>
      <firstName>Bill</firstName>
      <lastName>Blart</lastName>
    </name>
  </person>
  <person uuid="" pureId="321" externalId="abc321" externalIdSource="synchronisedPerson" externallyManaged="true">
    <name>
      <firstName>Frank</firstName>
      <lastName>Carl</lastName>
    </name>
  </person>
</result>', headers: {})
      get_pure_ids_obj.call
      expect(PureId.all.count).to eq(1)
      expect(PureId.find_by(pure_id: 123).faculty.access_id).to eq('abc123')
    end
  end

end
