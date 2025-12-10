require 'rails_helper'

RSpec.describe Committee, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:faculty).required }
  end

  describe 'database columns' do
    it { is_expected.to have_db_column(:student_fname).of_type(:string) }
    it { is_expected.to have_db_column(:student_mname).of_type(:string) }
    it { is_expected.to have_db_column(:student_lname).of_type(:string) }
    it { is_expected.to have_db_column(:role).of_type(:string) }
    it { is_expected.to have_db_column(:thesis_title).of_type(:string) }
    it { is_expected.to have_db_column(:degree_type).of_type(:string) }
    it { is_expected.to have_db_column(:faculty_id).of_type(:integer) }

    it 'has faculty_id as bigint in the database' do
      column = described_class.columns_hash['faculty_id']

      expect(column.limit).to eq(8)
      expect(column.sql_type).to match(/bigint/i)
    end
  end
end
