require "rails_helper"

RSpec.describe Committee, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:faculty).required }
  end

  describe "database columns" do
    it { is_expected.to have_db_column(:student_name).of_type(:string) }
    it { is_expected.to have_db_column(:role).of_type(:string) }
    it { is_expected.to have_db_column(:thesis_title).of_type(:string) }
    it { is_expected.to have_db_column(:degree_type).of_type(:string) }

    # ActiveRecord exposes MySQL BIGINT as :integer
    it { is_expected.to have_db_column(:faculty_id).of_type(:integer) }

    # Extra check that it is really BIGINT at the SQL level
    it "has faculty_id as bigint in the database" do
      column = described_class.columns_hash["faculty_id"]

      # This limit comes from the underlying type
      expect(column.limit).to eq(8)               # 8 bytes = bigint
      expect(column.sql_type).to match(/bigint/i) 
    end
  end
end
