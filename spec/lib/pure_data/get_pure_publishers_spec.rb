require 'rails_helper'
require 'pure_data/get_pure_publishers'

RSpec.describe GetPurePublishers do

  let(:get_pure_publishers_obj) {GetPurePublishers.new}

  before(:each) do
    faculty = Faculty.create(access_id: 'dfg345')

    Publication.create(faculty: faculty,
                       title: 'Cool',
                       journal_uuid: 'abc123',
                       publisher: nil)
    Publication.create(faculty: faculty,
                       title: 'Cooler',
                       journal_uuid: 'cba123',
                       publisher: nil)
  end

  describe '#call' do
    it 'should update publications to have publisher' do
      stub_request(:get, "https://pennstate.pure.elsevier.com/ws/api/511/journals/abc123").
         with(
           headers: {
       	  'Accept'=>'application/xml',
           }).
         to_return(status: 200, body: 
"<journal>
  <publisher>
    <name>Cool Publisher</name>
  </publisher>
</journal>", headers: {})
      stub_request(:get, "https://pennstate.pure.elsevier.com/ws/api/511/journals/cba123").
         with(
           headers: {
       	  'Accept'=>'application/xml',
       	  'Api-Key'=>'bf5beedf-55a2-4260-9708-b3b7466defef'
           }).
         to_return(status: 200, body: 
"<journal>
  <publisher>
    <name>Cooler Publisher</name>
  </publisher>
</journal>", headers: {})
      get_pure_publishers_obj.call
      expect(Publication.find_by(publisher: 'Cool Publisher').title).to eq('Cool')
    end
  end
end
