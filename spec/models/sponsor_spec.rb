require 'rails_helper'

describe Sponsor, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:sponsor_name).of_type(:string) }
    it { is_expected.to have_db_column(:sponsor_type).of_type(:string) }

    it { is_expected.to have_db_index(:sponsor_name).unique(true) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:contracts) }
  end
end

