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

    before do
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
  end

  describe '#name' do
    it 'returns the job name' do
      expect(described_class.new.send(:name)).to eq('Committee Integration')
    end
  end
end
