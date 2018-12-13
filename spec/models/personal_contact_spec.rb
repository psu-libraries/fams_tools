require 'rails_helper'

describe 'the personal contacts table', type: :model do
  subject { PersonalContact.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:faculty_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:uid).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:telephone_number).of_type(:string) }
  it { is_expected.to have_db_column(:postal_address).of_type(:string) }
  it { is_expected.to have_db_column(:department).of_type(:string) }
  it { is_expected.to have_db_column(:title).of_type(:string) }
  it { is_expected.to have_db_column(:ps_research).of_type(:text) }
  it { is_expected.to have_db_column(:ps_teaching).of_type(:text) }
  it { is_expected.to have_db_column(:ps_office_address).of_type(:string) }
  it { is_expected.to have_db_column(:facsimile_telephone_number).of_type(:string) }
  it { is_expected.to have_db_column(:cn).of_type(:string) }
  it { is_expected.to have_db_column(:mail).of_type(:string) }

  it { is_expected.to have_db_index(:faculty_id).unique(true) }
end

describe PersonalContact, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:faculty_id) }
    it { is_expected.to validate_presence_of(:uid) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:faculty) }
  end
end

