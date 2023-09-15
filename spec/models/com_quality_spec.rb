require 'rails_helper'

describe ComQuality, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:com_id).of_type(:string) }
    it { is_expected.to have_db_column(:course_year).of_type(:string) }
    it { is_expected.to have_db_column(:course).of_type(:string) }
    it { is_expected.to have_db_column(:event_type).of_type(:string) }
    it { is_expected.to have_db_column(:faculty_name).of_type(:string) }
    it { is_expected.to have_db_column(:evaluation_type).of_type(:string) }
    it { is_expected.to have_db_column(:average_rating).of_type(:float) }
    it { is_expected.to have_db_column(:num_evaluations).of_type(:integer) }

    it { is_expected.to have_db_index(%i[com_id course course_year]).unique(true) }
    it { is_expected.to have_db_index([:faculty_id]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:faculty) }
  end
end
