require 'rails_helper'

describe Yearly, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:faculty_id).of_type(:integer) }
    it { is_expected.to have_db_column(:academic_year).of_type(:string) }
    it { is_expected.to have_db_column(:campus).of_type(:string) }
    it { is_expected.to have_db_column(:campus_name).of_type(:string) }
    it { is_expected.to have_db_column(:college).of_type(:string) }
    it { is_expected.to have_db_column(:college_name).of_type(:string) }
    it { is_expected.to have_db_column(:school).of_type(:string) }
    it { is_expected.to have_db_column(:division).of_type(:string) }
    it { is_expected.to have_db_column(:institute).of_type(:string) }
    it { is_expected.to have_db_column(:departments).of_type(:text) }
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:rank).of_type(:string) }
    it { is_expected.to have_db_column(:tenure).of_type(:string) }
    it { is_expected.to have_db_column(:endowed_position).of_type(:string) }
    it { is_expected.to have_db_column(:graduate).of_type(:string) }
    it { is_expected.to have_db_column(:time_status).of_type(:string) }
    it { is_expected.to have_db_column(:hr_code).of_type(:string) }

    it { is_expected.to have_db_index(:faculty_id).unique(true) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:faculty) }
  end
end
