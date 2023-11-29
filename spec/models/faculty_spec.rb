require 'rails_helper'

describe Faculty, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:access_id).of_type(:string) }
    it { is_expected.to have_db_column(:user_id).of_type(:integer) }
    it { is_expected.to have_db_column(:f_name).of_type(:string) }
    it { is_expected.to have_db_column(:m_name).of_type(:string) }
    it { is_expected.to have_db_column(:l_name).of_type(:string) }
    it { is_expected.to have_db_column(:college).of_type(:string) }
    it { is_expected.to have_db_column(:campus).of_type(:string) }

    it { is_expected.to have_db_index(:access_id).unique(true) }
  end

  describe 'associations' do
    it { is_expected.to have_one(:personal_contact) }
    it { is_expected.to have_many(:publication_faculty_links) }
    it { is_expected.to have_many(:publications) }
    it { is_expected.to have_many(:contract_faculty_links) }
    it { is_expected.to have_many(:contracts) }
    it { is_expected.to have_many(:sections) }
    it { is_expected.to have_many(:courses) }
    it { is_expected.to have_many(:yearlies) }
    it { is_expected.to have_many(:com_efforts) }
    it { is_expected.to have_many(:com_qualities) }
  end
end
