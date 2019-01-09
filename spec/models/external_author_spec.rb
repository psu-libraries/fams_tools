require 'rails_helper'

describe ExternalAuthor, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:publication_id).of_type(:integer) }
    it { is_expected.to have_db_column(:f_name).of_type(:string) }
    it { is_expected.to have_db_column(:m_name).of_type(:string) }
    it { is_expected.to have_db_column(:l_name).of_type(:string) }
    it { is_expected.to have_db_column(:role).of_type(:string) }
    it { is_expected.to have_db_column(:extOrg).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

    it { is_expected.to have_db_index(:publication_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:publication) }
  end
end
