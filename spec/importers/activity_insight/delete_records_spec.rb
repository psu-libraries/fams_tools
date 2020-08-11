require 'importers/importers_helper'

RSpec.describe DeleteRecords do
  subject(:delete_records) { described_class }

  let(:request_body) do
    "<?xml version=\"1.0\"?>\n<Data>\n  <SCHTEACH>\n    <item id=\"204643792896\"/>\n    <item id=\"204643794944\"/>\n    <item id=\"204644020224\"/>\n    <item id=\"204644018176\"/>\n    <item id=\"204644022272\"/>\n    <item id=\"204644024320\"/>\n    <item id=\"204644263936\"/>\n  </SCHTEACH>\n</Data>\n"
  end

  context 'when deleting SCHTEACH records in beta' do
    it 'generates an xml request to Digital Measures webservices' do
      stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University").
          with(
              body: request_body,
              headers: {
                  'Content-Type'=>'text/xml'
              }).
          to_return(status: 200, body: "", headers: {})

      allow_any_instance_of(DeleteRecords).to receive(:csv_path).and_return("#{Rails.root}/spec/fixtures/delete.csv")
      object = delete_records.new('SCHTEACH', :beta)
      object.delete
    end
  end
end
