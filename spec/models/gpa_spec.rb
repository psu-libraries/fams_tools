require 'rails_helper'

describe Gpa, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:faculty_id).of_type(:integer) }
    it { is_expected.to have_db_column(:semester).of_type(:string) }
    it { is_expected.to have_db_column(:year).of_type(:integer) }
    it { is_expected.to have_db_column(:course_prefix).of_type(:string) }
    it { is_expected.to have_db_column(:course_number).of_type(:string) }
    it { is_expected.to have_db_column(:course_number_suffix).of_type(:string) }
    it { is_expected.to have_db_column(:section_number).of_type(:string) }
    it { is_expected.to have_db_column(:campus).of_type(:string) }
    it { is_expected.to have_db_column(:number_of_grades).of_type(:integer) }
    it { is_expected.to have_db_column(:course_gpa).of_type(:float) }
    it { is_expected.to have_db_column(:grade_dist_a).of_type(:integer) }
    it { is_expected.to have_db_column(:grade_dist_a_minus).of_type(:integer) }
    it { is_expected.to have_db_column(:grade_dist_b_plus).of_type(:integer) }
    it { is_expected.to have_db_column(:grade_dist_b).of_type(:integer) }
    it { is_expected.to have_db_column(:grade_dist_b_minus).of_type(:integer) }
    it { is_expected.to have_db_column(:grade_dist_c_plus).of_type(:integer) }
    it { is_expected.to have_db_column(:grade_dist_c).of_type(:integer) }
    it { is_expected.to have_db_column(:grade_dist_d).of_type(:integer) }
    it { is_expected.to have_db_column(:grade_dist_f).of_type(:integer) }
    it { is_expected.to have_db_column(:grade_dist_w).of_type(:integer) }
    it { is_expected.to have_db_column(:grade_dist_ld).of_type(:integer) }
    it { is_expected.to have_db_column(:grade_dist_other).of_type(:integer) }

    it { is_expected.to have_db_index([:faculty_id, :semester, :year, :course_prefix, :course_number, :course_number_suffix, :section_number, :campus]).unique(true) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:faculty) }
  end
end
