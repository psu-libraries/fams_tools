require 'importers/importers_helper'

RSpec.describe CommitteeData::EtdaImporter do
  subject(:importer) { described_class.new }

  let!(:faculty)     { create(:faculty, access_id: 'abc123') }
  let!(:faculty_one) { create(:faculty, access_id: 'mpk6156') }
  let!(:faculty_two) { create(:faculty, access_id: 'aez1236') }

  let(:client) { instance_double(Etda::CommitteeRecordsClient) }

  describe '#import_all' do
    context 'when the import finds a committee' do
      let(:committee_data) do
        { 'student_fname' => 'Spider', 'student_lname' => 'Man',
          'role' => 'advisor', 'title' => 'My Thesis', 'degree_type' => 'Dissertation',
          'degree_name' => 'PhD',
          'approval_started_at' => 1.month.ago.iso8601,
          'final_submission_approved_at' => '2026-01-15T10:30:00Z',
          'submission_status' => 'released for publication' }
      end

      before do
        allow(Etda::CommitteeRecordsClient).to receive(:new).and_return(client)
        allow(client).to receive(:faculty_committees).with('abc123').and_return({ 'committees' => [committee_data] })
        allow(client).to receive(:faculty_committees).with('mpk6156').and_return({ 'committees' => [] })
        allow(client).to receive(:faculty_committees).with('aez1236').and_return({ 'committees' => [] })
      end

      it 'creates a committee with the correct attributes' do
        expect { importer.import_all }.to change(Committee, :count).by(3)
        expect(Committee.last.student_fname).to eq('Spider')
        expect(Committee.last.student_lname).to eq('Man')
        expect(Committee.last.role).to eq('Advisor')
        expect(Committee.last.thesis_title).to eq('My Thesis')
        expect(Committee.last.type_of_work).to eq('Dissertation Committee')
        expect(Committee.last.degree_name).to eq('PhD')
        expect(Committee.last.stage_of_completion).to eq('Completed')
        expect(Committee.last.start_year).to eq(1.month.ago.year)
        expect(Committee.last.start_month).to eq(1.month.ago.month)
        expect(Committee.last.completion_year).to eq(2026)
        expect(Committee.last.completion_month).to eq(1)
      end
    end

    context 'when degree_name is nil in the API response' do
      let(:committee_data) do
        { 'student_fname' => 'Spider', 'student_lname' => 'Man',
          'role' => 'advisor', 'title' => 'My Thesis', 'degree_type' => 'Dissertation',
          'degree_name' => nil,
          'approval_started_at' => 1.month.ago.iso8601,
          'final_submission_approved_at' => '2026-01-15T10:30:00Z',
          'submission_status' => 'released for publication' }
      end

      before do
        allow(Etda::CommitteeRecordsClient).to receive(:new).and_return(client)
        allow(client).to receive(:faculty_committees).with('abc123').and_return({ 'committees' => [committee_data] })
        allow(client).to receive(:faculty_committees).with('mpk6156').and_return({ 'committees' => [] })
        allow(client).to receive(:faculty_committees).with('aez1236').and_return({ 'committees' => [] })
      end

      it 'stores nil for degree_name' do
        importer.import_all
        expect(Committee.last.degree_name).to be_nil
      end
    end

    context 'when final_submission_approved_at is nil' do
      let(:committee_data) do
        { 'student_fname' => 'Spider', 'student_lname' => 'Man',
          'role' => 'advisor', 'title' => 'My Thesis', 'degree_type' => 'Dissertation',
          'approval_started_at' => 1.month.ago.iso8601,
          'final_submission_approved_at' => nil,
          'submission_status' => 'waiting for publication release' }
      end

      before do
        allow(Etda::CommitteeRecordsClient).to receive(:new).and_return(client)
        allow(client).to receive(:faculty_committees).with('abc123').and_return({ 'committees' => [committee_data] })
        allow(client).to receive(:faculty_committees).with('mpk6156').and_return({ 'committees' => [] })
        allow(client).to receive(:faculty_committees).with('aez1236').and_return({ 'committees' => [] })
      end

      it 'stores nil for completion_year and completion_month' do
        importer.import_all
        expect(Committee.last.completion_year).to be_nil
        expect(Committee.last.completion_month).to be_nil
      end
    end
  end

  describe '#map_type_of_work' do
    it 'maps Dissertation to Dissertation Committee' do
      expect(importer.send(:map_type_of_work, 'Dissertation')).to eq('Dissertation Committee')
    end

    it "maps Master Thesis to Master's Committee" do
      expect(importer.send(:map_type_of_work, 'Master Thesis')).to eq("Master's Committee")
    end

    it 'maps Thesis to Undergraduate Honors Thesis' do
      expect(importer.send(:map_type_of_work, 'Thesis')).to eq('Undergraduate Honors Thesis')
    end

    it "maps Final Paper to Master's Paper Committee" do
      expect(importer.send(:map_type_of_work, 'Final Paper')).to eq("Master's Paper Committee")
    end

    it 'raises DegreeTypeError for unknown degree types' do
      expect { importer.send(:map_type_of_work, 'DMA') }.to raise_error(CommitteeData::EtdaImporter::DegreeTypeError)
    end

    it 'returns nil for blank degree type' do
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

  describe '#extract_month' do
    subject(:extract) { importer.send(:extract_month, date_string) }

    context 'with a valid ISO8601 date string' do
      let(:date_string) { '2026-01-15T10:30:00Z' }

      it { is_expected.to eq(1) }
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

  describe '#within_last_six_months?' do
    it 'returns true for a date within the last 6 months' do
      recent_date = 1.month.ago.iso8601
      expect(importer.send(:within_last_six_months?, recent_date)).to be true
    end

    it 'returns false for a date older than 6 months' do
      old_date = 1.year.ago.iso8601
      expect(importer.send(:within_last_six_months?, old_date)).to be false
    end

    it 'returns false for a nil date' do
      expect(importer.send(:within_last_six_months?, nil)).to be false
    end

    it 'returns false for a blank date' do
      expect(importer.send(:within_last_six_months?, '')).to be false
    end
  end

  describe '#determine_completion_stage' do
    it 'returns Completed when final submission date is present' do
      result = importer.send(:determine_completion_stage, '2026-01-15T10:30:00Z')
      expect(result).to eq('Completed')
    end

    it 'returns In Process when final submission date is nil' do
      result = importer.send(:determine_completion_stage, nil)
      expect(result).to eq('In Process')
    end
  end

  it 'rescues StandardError and logs it' do
    allow(Etda::CommitteeRecordsClient).to receive(:new).and_return(client)
    allow(client).to receive(:faculty_committees)
      .and_raise(Etda::CommitteeRecordsClient::CommitteeRecordsClientError, 'API down')

    expect(Rails.logger).to receive(:error).with(/mpk6156.*API down/)
    expect(Rails.logger).to receive(:error).with(/abc123.*API down/)
    expect(Rails.logger).to receive(:error).with(/aez1236.*API down/)
    expect { importer.import_all }.not_to raise_error
  end

  describe 'multi-endpoint import' do
    it 'imports committees from all endpoints' do
      faculty = create(:faculty)

      allow(Etda::CommitteeRecordsClient).to receive(:new).and_return(client)

      etda_data = {
        'committees' => [
          {
            'student_fname' => 'John',
            'student_lname' => 'Doe',
            'role' => 'Chair',
            'title' => 'Thesis 1',
            'degree_type' => 'Dissertation',
            'degree_name' => 'PhD',
            'approval_started_at' => 2.months.ago.to_date.to_s,
            'final_submission_approved_at' => nil
          }
        ]
      }

      honors_data = {
        'committees' => [
          {
            'student_fname' => 'Jane',
            'student_lname' => 'Smith',
            'role' => 'Member',
            'title' => 'Honors Thesis',
            'degree_type' => 'Thesis',
            'degree_name' => 'BA',
            'approval_started_at' => 1.month.ago.to_date.to_s,
            'final_submission_approved_at' => nil
          }
        ]
      }

      empty_data = { 'committees' => [] }

      allow(client).to receive(:faculty_committees)
                       .with(faculty.access_id)
                       .and_return(etda_data, honors_data, empty_data, empty_data)

      importer.import_all

      expect(faculty.committees.count).to eq(2)
      expect(faculty.committees.find_by(student_fname: 'John')).to be_present
      expect(faculty.committees.find_by(student_fname: 'Jane')).to be_present
    end

    it 'continues importing if one endpoint fails' do
      faculty = create(:faculty)

      allow(Etda::CommitteeRecordsClient).to receive(:new).and_return(client)

      etda_data = {
        'committees' => [
          {
            'student_fname' => 'John',
            'student_lname' => 'Doe',
            'role' => 'Chair',
            'title' => 'Thesis',
            'degree_type' => 'Dissertation',
            'degree_name' => 'PhD',
            'approval_started_at' => 2.months.ago.to_date.to_s,
            'final_submission_approved_at' => nil
          }
        ]
      }

      allow(client).to receive(:faculty_committees)
                       .with(faculty.access_id)
                       .and_return(etda_data)
                       .and_raise(Etda::CommitteeRecordsClient::CommitteeRecordsClientError, 'API unavailable')
                       .and_return({ 'committees' => [] })
                       .and_return({ 'committees' => [] })

      expect { importer.import_all }.not_to raise_error

      expect(faculty.committees.count).to eq(1)
    end
  end
end
