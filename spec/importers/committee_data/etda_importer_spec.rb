require 'importers/importers_helper'

RSpec.describe CommitteeData::EtdaImporter do
  subject(:importer) { described_class.new }

  let(:faculty)     { create(:faculty, access_id: 'abc123') }
  let(:faculty_one) { create(:faculty, access_id: 'mpk6156') }
  let(:faculty_two) { create(:faculty, access_id: 'aez1236') }

  let(:client) { instance_double(Etda::CommitteeRecordsClient) }

  before do
    allow(Etda::CommitteeRecordsClient).to receive(:new).and_return(client)
  end

  describe '#import_all' do
    context 'when the import finds a committee' do
      let(:api_response) do
        { data: { 'committees' => [
          { 'student_fname' => 'Spider', 'student_lname' => 'Man',
            'role' => 'advisor', 'title' => 'My Thesis', 'degree_name' => 'PhD',
            'approval_started_at' => '2024-08-15T10:30:00Z',
            'final_submission_approved_at' => '2026-01-15T10:30:00Z',
            'submission_status' => 'released for publication' }
        ] } }
      end

      before do
        faculty
        faculty_one
        faculty_two
        allow(client).to receive(:faculty_committees).and_return(api_response)
      end

      it 'creates a committee with the correct attributes' do
        expect { importer.import_all }.to change(Committee, :count).by(3)
        expect(Committee.last.student_fname).to eq('Spider')
        expect(Committee.last.student_lname).to eq('Man')
        expect(Committee.last.role).to eq('Advisor')
        expect(Committee.last.role_other_explanation).to be_nil
        expect(Committee.last.thesis_title).to eq('My Thesis')
        expect(Committee.last.degree_type).to eq('PhD')
        expect(Committee.last.type_of_work).to eq('Ph.D. Dissertation')
        expect(Committee.last.stage_of_completion).to eq('Completed')
        expect(Committee.last.start_year).to eq(2024)
        expect(Committee.last.completion_year).to eq(2026)
      end

      context 'when role does not match any valid Activity Insight value' do
        let(:api_response) do
          { data: { 'committees' => [
            { 'student_fname' => 'Spider', 'student_lname' => 'Man',
              'role' => 'External Reviewer', 'title' => 'My Thesis', 'degree_name' => 'PhD',
              'approval_started_at' => nil,
              'final_submission_approved_at' => nil,
              'submission_status' => 'waiting for publication release' }
          ] } }
        end

        it 'saves role as Other and stores original role in role_other_explanation' do
          importer.import_all
          committee = Committee.last
          expect(committee.role).to eq('Other')
          expect(committee.role_other_explanation).to eq('External Reviewer')
        end
      end
    end
  end

  describe '#map_type_of_work' do
    it 'maps PhD with Advisor role to Ph.D. Dissertation' do
      expect(importer.send(:map_type_of_work, 'PhD', 'Advisor')).to eq('Ph.D. Dissertation')
    end

    it 'maps PhD with Chairperson role to Ph.D. Dissertation' do
      expect(importer.send(:map_type_of_work, 'PhD', 'Chairperson')).to eq('Ph.D. Dissertation')
    end

    it 'maps PhD with Member role to Ph.D. Dissertation Committee' do
      expect(importer.send(:map_type_of_work, 'PhD', 'Member')).to eq('Ph.D. Dissertation Committee')
    end

    it 'maps Ph.D. to Ph.D. Dissertation Committee when no role given' do
      expect(importer.send(:map_type_of_work, 'Ph.D.')).to eq('Ph.D. Dissertation Committee')
    end

    it 'maps MS with Advisor role to Master\'s Thesis' do
      expect(importer.send(:map_type_of_work, 'MS', 'Advisor')).to eq("Master's Thesis")
    end

    it 'maps MS with Member role to Master\'s Thesis Committee' do
      expect(importer.send(:map_type_of_work, 'MS', 'Member')).to eq("Master's Thesis Committee")
    end

    it 'maps MA to Master\'s Thesis Committee when no role given' do
      expect(importer.send(:map_type_of_work, 'MA')).to eq("Master's Thesis Committee")
    end

    it 'maps undergraduate degrees to Undergraduate Research' do
      expect(importer.send(:map_type_of_work, 'BS')).to eq('Undergraduate Research')
    end

    it 'maps postdoc to Postdoctoral Mentorship' do
      expect(importer.send(:map_type_of_work, 'Postdoc')).to eq('Postdoctoral Mentorship')
    end

    it 'maps honors to Honors Thesis' do
      expect(importer.send(:map_type_of_work, 'HONORS')).to eq('Honors Thesis')
    end

    it 'defaults to Dissertation Committee for unknown degree types' do
      expect(importer.send(:map_type_of_work, 'DMA')).to eq('Dissertation Committee')
    end

    it 'returns nil for blank degree name' do
      expect(importer.send(:map_type_of_work, nil)).to be_nil
      expect(importer.send(:map_type_of_work, '')).to be_nil
    end
  end

  describe '#extract_year' do
    subject(:extract) { importer.send(:extract_year, date_string) }

    context 'with a valid ISO8601 date string' do
      let(:date_string) { '2026-01-15T10:30:00Z' }

      it { is_expected.to eq(2026) }
    end

    context 'with nil' do
      let(:date_string) { nil }

      it { is_expected.to be_nil }
    end

    context 'with an empty string' do
      let(:date_string) { '' }

      it { is_expected.to be_nil }
    end

    context 'with an invalid date string' do
      let(:date_string) { 'not-a-date' }

      it { is_expected.to be_nil }
    end
  end

  describe '#determine_completion_stage' do
    it 'returns Completed when final submission date is present' do
      result = importer.send(:determine_completion_stage, '2026-01-15T10:30:00Z', 'released for publication')
      expect(result).to eq('Completed')
    end

    it 'returns In Process when final submission date is nil and not withdrawn' do
      result = importer.send(:determine_completion_stage, nil, 'waiting for publication release')
      expect(result).to eq('In Process')
    end

    it 'returns Withdrew when submission status indicates withdrawal' do
      result = importer.send(:determine_completion_stage, nil, 'withdrawn by student')
      expect(result).to eq('Withdrew')
    end

    it 'handles nil submission status gracefully' do
      result = importer.send(:determine_completion_stage, nil, nil)
      expect(result).to eq('In Process')
    end
  end

  it 'rescues CommitteeRecordsClientError and logs it' do
    faculty
    allow(client).to receive(:faculty_committees)
      .and_raise(Etda::CommitteeRecordsClient::CommitteeRecordsClientError, 'API down')

    expect(Rails.logger).to receive(:error).with(/abc123.*API down/)
    expect { importer.import_all }.not_to raise_error
  end
end
