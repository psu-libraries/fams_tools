require 'rails_helper'

describe ContractFacultyLink, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:role).of_type(:string) }
    it { is_expected.to have_db_column(:pct_credit).of_type(:integer) }
    it { is_expected.to have_db_column(:contract_id).of_type(:integer) }
    it { is_expected.to have_db_column(:faculty_id).of_type(:integer) }

    it { is_expected.to have_db_index(:faculty_id) }
    it { is_expected.to have_db_index(%i[contract_id faculty_id]).unique(true) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:faculty) }
    it { is_expected.to belong_to(:contract) }
  end
end
