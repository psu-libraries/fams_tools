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
      described_class.new.integrate(target)
      expect(CommitteeData::CommitteeXmlBuilder).to have_received(:new)
    end

    it 'initializes ActivityInsight::IntegrateData with correct arguments' do
      described_class.new.integrate(target)

      expect(ActivityInsight::IntegrateData)
        .to have_received(:new)
        .with(xml_enumerator, target, :post)
    end

    it 'calls integrate on the integrator and returns its errors' do
      result = described_class.new.integrate(target)
      expect(integrator_double).to have_received(:integrate)
      expect(result).to eq([])
    end
  end

  describe '#name' do
    it 'returns the job name' do
      expect(described_class.new.name).to eq('Committee Integration')
    end
  end
end
