require 'rails_helper'

describe Integration, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:process_type).of_type(:string) }
    it { is_expected.to have_db_column(:is_active).of_type(:boolean) }
  end

  describe '#is_running?' do
    it 'checks if integration is_active' do
      integration = FactoryBot.create :integration
      expect(Integration.is_running?).to eq false
      integration.update_attribute :is_active, true
      expect(Integration.is_running?).to eq true
    end
  end

  describe '#start' do
    it 'changes is_active to true' do
      integration = FactoryBot.create :integration
      Integration.start
      expect(Integration.find(integration.id).is_active).to eq true
    end
  end

  describe '#stop' do
    it 'changes is_active to false' do
      integration = FactoryBot.create :integration
      Integration.stop
      expect(Integration.find(integration.id).is_active).to eq false
    end
  end

  describe '#seed' do
    it 'seeds the db' do
      expect(Integration.count).to eq 0
      Integration.seed
      expect(Integration.count).to eq 1
      expect(Integration.first.process_type).to eq 'integration'
      expect(Integration.first.is_active).to eq false
    end
  end
end
