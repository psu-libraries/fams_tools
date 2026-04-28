require 'rails_helper'

RSpec.describe CommitteeRoleNormalizer do
  describe '.normalize' do
    it 'maps co-chair roles correctly' do
      expect(
        described_class.normalize('Co-Chair & Dissertation Advisor')
      ).to eq(['Co-Chairperson', nil])
    end

    it 'maps chair roles correctly' do
      expect(
        described_class.normalize('Chair of Committee')
      ).to eq(['Chairperson', nil])
    end

    it 'prioritizes chair over advisor when both appear' do
      expect(
        described_class.normalize('Chair & Dissertation Advisor')
      ).to eq(['Chairperson', nil])
    end

    it 'maps advisor roles' do
      expect(
        described_class.normalize('Dissertation Advisr')
      ).to eq(['Advisor', nil])
    end

    it 'maps member and representative roles' do
      expect(
        described_class.normalize('Committee Member & Dean Grad Sch Rep')
      ).to eq(['Member', nil])
    end

    it 'returns Other with original text for unknown roles' do
      expect(
        described_class.normalize('Some Weird ETDA Thing')
      ).to eq(['Other', 'Some Weird ETDA Thing'])
    end

    it 'returns Other with nil text for blank values' do
      expect(
        described_class.normalize(nil)
      ).to eq(['Other', nil])
    end
  end
end
