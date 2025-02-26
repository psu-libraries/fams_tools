require 'rails_helper'
require_relative '../../app/importers/activity_insight/integrate_data'
require_relative '../../app/importers/lionpath_data/lionpath_populate_db'
require_relative '../../app/importers/com_data/com_effort_populate_db'
require_relative '../../app/importers/com_data/com_quality_populate_db'

RSpec.describe ApplicationJob do
  let(:params) { { key1: 'value1', key2: 'value2' } }
  let!(:integration) { FactoryBot.create(:integration) }

  context 'when no other integration is running' do
    it 'runs the integration' do
      allow_any_instance_of(OspIntegrateJob).to receive(:perform).and_return true
      expect(Integration).to receive(:start)
      expect_any_instance_of(described_class).to receive(:prevent_concurrent_jobs)
      expect { OspIntegrateJob.perform_now(params, '/log/path') }.not_to change { Integration.running? }
    end

    it 'changes integration is_active to true' do
      # This is a hacky way of testing the start
      error = StandardError.new('Test error')
      allow_any_instance_of(OspIntegrateJob).to receive(:integrate).and_raise error
      allow_any_instance_of(OspIntegrateJob).to receive(:clean_up).and_return true
      expect { OspIntegrateJob.perform_now(params, '/log/path') }.to raise_error StandardError
      expect(Integration.running?).to eq true
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end

  context 'when another integration is running' do
    it 'returns a ConcurrentJobsError' do
      allow(Integration).to receive(:running?).and_return true
      expect(Integration).not_to receive(:start)
      expect { OspIntegrateJob.perform_now(params, '/log/path') }.to raise_error described_class::ConcurrentJobsError
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  context 'when StandardError is raised' do
    it 'discards and runs cleanup' do
      error = StandardError.new('Test error')
      allow_any_instance_of(OspIntegrateJob).to receive(:integrate).and_raise error
      expect(Integration).to receive(:start)
      expect_any_instance_of(OspIntegrateJob).to receive(:integration_stop)
      expect { OspIntegrateJob.perform_now(params, '/log/path') }.to raise_error StandardError
      expect(Integration.running?).to eq false
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end

  context 'when running automated lionpath integration' do
    it "accepts _user_uploaded parameter as 'false' and calls system" do
      allow_any_instance_of(LionpathIntegrateJob).to receive(:`).and_return(true)
      allow_any_instance_of(LionpathIntegrateJob).to receive(:populate_course_data).and_return(true)
      allow_any_instance_of(LionpathIntegrateJob).to receive(:integrate_course_data).and_return([{}])
      LionpathIntegrateJob.perform_now(params, 'log/courses_errors.log', false)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  context 'when running automated com effort integration' do
    it "accepts _user_uploaded parameter as 'false' and calls system" do
      allow_any_instance_of(ComEffortIntegrateJob).to receive(:`).and_return(true)
      allow_any_instance_of(ComEffortIntegrateJob).to receive(:populate_course_data).and_return(true)
      allow_any_instance_of(ComEffortIntegrateJob).to receive(:integrate_course_data).and_return([{}])
      ComEffortIntegrateJob.perform_now(params, 'log/com_effort_errors.log', false)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  context 'when running automated com quality integration' do
    it "accepts _user_uploaded parameter as 'false' and calls system" do
      allow_any_instance_of(ComQualityIntegrateJob).to receive(:`).and_return(true)
      allow_any_instance_of(ComQualityIntegrateJob).to receive(:populate_course_data).and_return(true)
      allow_any_instance_of(ComQualityIntegrateJob).to receive(:integrate_course_data).and_return([{}])
      ComQualityIntegrateJob.perform_now(params, 'log/com_quality_errors.log', false)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  context 'when running automated contract/grants integration' do
    it "accepts _user_uploaded parameter as 'false' and calls system" do
      allow_any_instance_of(OspIntegrateJob).to receive(:`).and_return(true)
      allow_any_instance_of(OspIntegrateJob).to receive(:populate_db).and_return(true)
      allow_any_instance_of(OspIntegrateJob).to receive(:remove_dups).and_return(true)
      allow_any_instance_of(OspIntegrateJob).to receive(:integrator).and_return([{}])
      OspIntegrateJob.perform_now(params, 'log/osp_errors.log', false)
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  context 'when AI Webservices returns errors' do
    it 'parses errors and displays it in a log file and sends error email' do
      allow_any_instance_of(OspIntegrateJob).to receive(:integrate).and_return([{ response: 'error',
                                                                                  affected_faculty: 'abc123',
                                                                                  affected_osps: '123456' },
                                                                                { response: 'error',
                                                                                  affected_faculty: 'abc123',
                                                                                  affected_osps: '123456' }])
      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).twice
      expect(logger).to receive(:error).with(/Error:|Affected Faculty:|Affected OSPs|_______/).exactly(8).times

      OspIntegrateJob.perform_now({ target: :beta }, '/path', false)

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end

  context 'when an exception occurs during integration' do
    it 'handles exceptions, logs them and sends error email' do
      error = StandardError.new('Test error')
      allow_any_instance_of(OspIntegrateJob).to receive(:integrate).and_raise(error)

      logger = double('logger')
      allow(Logger).to receive(:new).and_return(logger)
      expect(logger).to receive(:info).once
      expect(logger).to receive(:error).with('Thrown Error: Test error')
      expect(logger).to receive(:error).with(kind_of(String)) # For backtrace

      expect { OspIntegrateJob.perform_now({ target: :beta }, '/path', false) }.to raise_error StandardError

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
