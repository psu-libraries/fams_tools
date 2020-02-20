require 'rails_helper'

RSpec.describe ApplicationJob do
  let(:params) { {key1: 'value1', key2: 'value2'} }

  context 'when no other integration is running' do
    it 'runs the integration' do
      allow_any_instance_of(OspIntegrateJob).to receive(:perform).and_return true
      expect_any_instance_of(ApplicationJob::Busy).to receive(:increment)
      expect{ OspIntegrateJob.perform_now(params, '/log/path') }.not_to change{ described_class::Busy.new('integration').value }
    end
  end

  context 'when another integration is running' do
    it 'returns a ConcurrentJobsError' do
      allow_any_instance_of(ApplicationJob::Busy).to receive(:value).and_return 1
      expect{ OspIntegrateJob.perform_now(params, '/log/path') }.to raise_error ApplicationJob::ConcurrentJobsError
    end
  end

  context 'when StandardError is raised' do
    it 'discards and runs cleanup' do
      allow_any_instance_of(OspIntegrateJob).to receive(:perform).and_raise StandardError
      expect_any_instance_of(ApplicationJob::Busy).to receive(:increment)
      expect_any_instance_of(ApplicationJob).to receive(:clean_up)
      expect{ OspIntegrateJob.perform_now(params, '/log/path') }.not_to change{ described_class::Busy.new('integration').value }
    end
  end
end