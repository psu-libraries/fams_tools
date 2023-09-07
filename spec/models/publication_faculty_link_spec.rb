require 'rails_helper'

describe PublicationFacultyLink, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:faculty_id).of_type(:integer) }
    it { is_expected.to have_db_column(:publication_id).of_type(:integer) }
    it { is_expected.to have_db_column(:category).of_type(:string) }
    it { is_expected.to have_db_column(:dtm).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

    it { is_expected.to have_db_index(:faculty_id) }
    it { is_expected.to have_db_index(:publication_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:faculty) }
    it { is_expected.to belong_to(:publication) }
  end
end
