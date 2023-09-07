require 'rails_helper'

describe Contract, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:osp_key).of_type(:integer) }
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:sponsor_id).of_type(:integer) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
    it { is_expected.to have_db_column(:submitted).of_type(:date) }
    it { is_expected.to have_db_column(:awarded).of_type(:date) }
    it { is_expected.to have_db_column(:requested).of_type(:integer) }
    it { is_expected.to have_db_column(:funded).of_type(:integer) }
    it { is_expected.to have_db_column(:total_anticipated).of_type(:integer) }
    it { is_expected.to have_db_column(:start_date).of_type(:date) }
    it { is_expected.to have_db_column(:end_date).of_type(:date) }
    it { is_expected.to have_db_column(:grant_contract).of_type(:string) }
    it { is_expected.to have_db_column(:base_agreement).of_type(:string) }
    it { is_expected.to have_db_column(:notfunded).of_type(:date) }

    it { is_expected.to have_db_index(:osp_key).unique(true) }
    it { is_expected.to have_db_index(:sponsor_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:sponsor) }
    it { is_expected.to have_many(:faculties) }
    it { is_expected.to have_many(:contract_faculty_links) }
  end
end
