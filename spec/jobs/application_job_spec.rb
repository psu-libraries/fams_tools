require 'rails_helper'

RSpec.describe ApplicationJob do
  let(:params) { {key1: 'value1', key2: 'value2'} }

  context 'when no other integration is running' do
    it 'runs the integration' do
      allow_any_instance_of(OspIntegrateJob).to receive(:perform).and_return true
      expect_any_instance_of(described_class::Busy).to receive(:increment)
      expect_any_instance_of(described_class).to receive(:prevent_concurrent_jobs)
      expect{ OspIntegrateJob.perform_now(params, '/log/path') }.not_to change{ described_class::Busy.new('integration').value }
    end

    it 'increments busy counter' do
      # This is a hacky way of testing the increment
      allow_any_instance_of(OspIntegrateJob).to receive(:perform).and_raise StandardError
      allow_any_instance_of(OspIntegrateJob).to receive(:clean_up).and_return true
      expect{ OspIntegrateJob.perform_now(params, '/log/path') }.to raise_error StandardError
      expect(described_class::Busy.new('integration').value).to eq 1
      # The following counter needs to be cleared or it will impact other tests
      described_class::Busy.clear
    end
  end

  context 'when another integration is running' do
    it 'returns a ConcurrentJobsError' do
      allow_any_instance_of(described_class::Busy).to receive(:value).and_return 1
      expect_any_instance_of(described_class::Busy).not_to receive(:increment)
      expect{ OspIntegrateJob.perform_now(params, '/log/path') }.to raise_error described_class::ConcurrentJobsError
    end
  end

  context 'when StandardError is raised' do
    it 'discards and runs cleanup' do
      allow_any_instance_of(OspIntegrateJob).to receive(:perform).and_raise StandardError
      expect_any_instance_of(described_class::Busy).to receive(:increment)
      expect_any_instance_of(OspIntegrateJob).to receive(:clear_busy)
      expect{ OspIntegrateJob.perform_now(params, '/log/path') }.to raise_error StandardError
      expect(described_class::Busy.new('integration').value).to eq 0
    end
  end
end