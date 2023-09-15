require 'rails_helper'

describe Course, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:academic_course_id).of_type(:integer) }
    it { is_expected.to have_db_column(:term).of_type(:string) }
    it { is_expected.to have_db_column(:calendar_year).of_type(:integer) }
    it { is_expected.to have_db_column(:course_short_description).of_type(:string) }
    it { is_expected.to have_db_column(:course_long_description).of_type(:text) }

    it { is_expected.to have_db_index(%i[academic_course_id term calendar_year]).unique(true) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:faculties) }
    it { is_expected.to have_many(:sections) }
  end
end
