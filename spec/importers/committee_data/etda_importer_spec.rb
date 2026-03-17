require 'importers/importers_helper'

RSpec.describe CommitteeData::EtdaImporter do
  subject(:importer) { described_class.new }

  let(:faculty) { create(:faculty, access_id: 'abc123') }
  let(:faculty_one)    { create(:faculty, access_id: 'mpk6156') }
  let(:faculty_two)    { create(:faculty, access_id: 'aez1236') }

  let(:client)     { instance_double(Etda::CommitteeRecordsClient) }
  let(:committees) { instance_double(committees) }

  before do
    allow(Etda::CommitteeRecordsClient).to receive(:new).and_return(client)
  end

  describe '#import_all' do
    context 'when the import finds a committee' do
      let(:api_response) do
        { data: { 'committees' => [
          { 'student_fname' => 'Spider', 'student_lname' => 'Man',
            'role' => 'advisor', 'title' => 'My Thesis', 'degree_name' => 'PhD' }
        ] } }
      end

      before do
        allow(client).to receive(:faculty_committees).and_return(api_response)
        allow(faculty).to receive(:committees).and_return(committees)
        allow(faculty_one).to receive(:committees).and_return(committees)
        allow(faculty_two).to receive(:committees).and_return(committees)
        allow(committees).to receive(:create!)
      end

      it 'creates a committee with the correct attributes' do
        expect { importer.import_all }.to change(Committee, :count).by(3)
        expect(Committee.last.student_fname).to eq('Spider')
        expect(Committee.last.student_lname).to eq('Man')
        expect(Committee.last.role).to eq('Advisor')
        expect(Committee.last.thesis_title).to eq('My Thesis')
        expect(Committee.last.degree_type).to eq('PhD')
      end
    end
  end

  it 'rescues CommitteeRecordsClientError and logs it' do
    expect(Rails.logger).to receive(:error).with(/abc123.*API down/)

    expect { importer.import_all }.not_to raise_error
  end
end
