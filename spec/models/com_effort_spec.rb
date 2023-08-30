require 'rails_helper'

describe ComEffort, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:com_id).of_type(:string) }
    it { is_expected.to have_db_column(:course_year).of_type(:string) }
    it { is_expected.to have_db_column(:course).of_type(:string) }
    it { is_expected.to have_db_column(:event_type).of_type(:string) }
    it { is_expected.to have_db_column(:faculty_name).of_type(:string) }
    it { is_expected.to have_db_column(:event).of_type(:string) }
    it { is_expected.to have_db_column(:event).of_type(:string) }
    it { is_expected.to have_db_column(:hours).of_type(:integer) }

    it { is_expected.to have_db_index([:com_id, :course, :event]).unique(true) }
    it { is_expected.to have_db_index([:faculty_id])}
  end

  describe 'associations' do
    it { is_expected.to belong_to(:faculty) }
  end
end
