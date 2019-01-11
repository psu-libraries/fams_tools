require 'rails_helper'

describe Presentation, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:faculty_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:dty_date).of_type(:date) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:org).of_type(:string) }
    it { is_expected.to have_db_column(:location).of_type(:string) }

    it { is_expected.to have_db_index(:faculty_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:faculty) }
    it { is_expected.to have_many(:presentation_contributors) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:faculty_id) }
  end
end
