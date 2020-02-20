require 'rails_helper'

RSpec.describe ApplicationJob do
  let(:params) { {key1: 'value1', key2: 'value2'} }
  let!(:integration) { FactoryBot.create :integration }

  context 'when no other integration is running' do
    it 'runs the integration' do
      allow_any_instance_of(OspIntegrateJob).to receive(:perform).and_return true
      expect(Integration).to receive(:start)
      expect_any_instance_of(described_class).to receive(:prevent_concurrent_jobs)
      expect{ OspIntegrateJob.perform_now(params, '/log/path') }.not_to change{ Integration.is_running? }
    end

    it 'changes integration is_active to true' do
      # This is a hacky way of testing the start
      allow_any_instance_of(OspIntegrateJob).to receive(:perform).and_raise StandardError
      allow_any_instance_of(OspIntegrateJob).to receive(:clean_up).and_return true
      expect{ OspIntegrateJob.perform_now(params, '/log/path') }.to raise_error StandardError
      expect(Integration.is_running?).to eq true
    end
  end

  context 'when another integration is running' do
    it 'returns a ConcurrentJobsError' do
      allow(Integration).to receive(:is_running?).and_return true
      expect(Integration).not_to receive(:start)
      expect{ OspIntegrateJob.perform_now(params, '/log/path') }.to raise_error described_class::ConcurrentJobsError
    end
  end

  context 'when StandardError is raised' do
    it 'discards and runs cleanup' do
      allow_any_instance_of(OspIntegrateJob).to receive(:perform).and_raise StandardError
      expect(Integration).to receive(:start)
      expect_any_instance_of(OspIntegrateJob).to receive(:integration_stop)
      expect{ OspIntegrateJob.perform_now(params, '/log/path') }.to raise_error StandardError
      expect(Integration.is_running?).to eq false
    end
  end
end