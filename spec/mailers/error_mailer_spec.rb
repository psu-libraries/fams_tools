require 'rails_helper'

RSpec.describe ErrorMailer, type: :mailer do
  describe '#error_email' do
    let(:integration_name) { 'TestIntegration' }
    let(:log_path) { Rails.root.join('spec', 'fixtures', 'files', 'test_error.log') }
    let(:mail) { described_class.error_email(integration_name, log_path) }
    let(:current_time) { DateTime.now.strftime("%B %d, %Y at %I:%M %p") }

    before do
      FileUtils.mkdir_p(File.dirname(log_path))
      File.write(log_path, 'Test error log content')
    end

    after do
      FileUtils.rm_f(log_path)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("AI Integration #{integration_name} Error")
      expect(mail.to).to eq(['bnb5508@psu.edu'])
      expect(mail.from).to eq(['L-FAMS@LISTS.PSU.EDU'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(integration_name)
      expect(mail.body.encoded).to include(current_time)
      expect(mail.body.encoded).to include('The full error log has been attached')
    end

    it 'includes the error log as an attachment' do
      expect(mail.attachments.count).to eq(1)
      expect(mail.attachments['error.log'].body.raw_source).to eq('Test error log content')
    end
  end
end