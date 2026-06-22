require 'rails_helper'

RSpec.describe ActivityInsightCommitteeJob, type: :job do
  describe '#integrate' do
    let(:target) { 'test_target' }
    let(:xml_enumerator) { ['<xml>test</xml>'].to_enum }

    let(:builder_double) do
      instance_double(
        CommitteeData::CommitteeXmlBuilder,
        xmls_enumerator: xml_enumerator
      )
    end

    let(:integrator_double) do
      instance_double(
        ActivityInsight::IntegrateData,
        integrate: []
      )
    end

    let(:importer_double) do
      instance_double(CommitteeData::EtdaImporter, import_all: nil)
    end

    before do
      allow(CommitteeData::EtdaImporter)
        .to receive(:new)
        .and_return(importer_double)

      allow(CommitteeData::CommitteeXmlBuilder)
        .to receive(:new)
        .and_return(builder_double)

      allow(ActivityInsight::IntegrateData)
        .to receive(:new)
        .with(xml_enumerator, target, :post)
        .and_return(integrator_double)
    end

    it 'calls the XML builder to get the xml enumerator' do
      expect(CommitteeData::CommitteeXmlBuilder).to receive(:new)
      described_class.new.integrate(target)
    end

    it 'initializes ActivityInsight::IntegrateData with correct arguments' do
      expect(ActivityInsight::IntegrateData)
        .to receive(:new)
        .with(xml_enumerator, target, :post)

      described_class.new.integrate(target)
    end

    it 'calls integrate on the integrator and returns its errors' do
      expect(integrator_double).to receive(:integrate)
      result = described_class.new.integrate(target)
      expect(result).to eq([])
    end

    describe 'window computation' do
      let(:current_date) { Date.new(2026, 6, 18) }

      before do
        allow(Date).to receive(:current).and_return(current_date)
      end

      it 'defaults to 1 month back (May 10 → June 10)' do
        expect(importer_double).to receive(:import_all).with(
          since: Date.new(2026, 5, 10),
          until_date: Date.new(2026, 6, 10)
        )
        described_class.new.integrate(target)
      end

      it 'with month_range: 3 fetches from March 10 → June 10' do
        expect(importer_double).to receive(:import_all).with(
          since: Date.new(2026, 3, 10),
          until_date: Date.new(2026, 6, 10)
        )
        described_class.new.integrate(target, month_range: 3)
      end

      it 'with month_range: 6 fetches from December 10 2025 → June 10 2026' do
        expect(importer_double).to receive(:import_all).with(
          since: Date.new(2025, 12, 10),
          until_date: Date.new(2026, 6, 10)
        )
        described_class.new.integrate(target, month_range: 6)
      end
    end
  end

  describe '#name' do
    it 'returns the job name' do
      expect(described_class.new.send(:name)).to eq('Committee Integration')
    end
  end
end
