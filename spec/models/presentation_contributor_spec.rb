require 'rails_helper'

describe PresentationContributor, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:presentation_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:f_name).of_type(:string) }
    it { is_expected.to have_db_column(:m_name).of_type(:string) }
    it { is_expected.to have_db_column(:l_name).of_type(:string) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:presentation) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:presentation_id) }
  end
end
