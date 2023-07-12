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

    #it { is_expected.to have_db_index([:academic_course_id, :term, :calendar_year]).unique(true) }
  end

  # describe 'associations' do
  #   it { is_expected.to have_many(:faculties) }
  #   it { is_expected.to have_many(:sections) }
  # end
end
