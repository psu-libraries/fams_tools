require 'rails_helper'

describe Section, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:class_campus_code).of_type(:string) }
    it { is_expected.to have_db_column(:cross_listed_flag).of_type(:string) }
    it { is_expected.to have_db_column(:course_number).of_type(:integer) }
    it { is_expected.to have_db_column(:course_suffix).of_type(:string) }
    it { is_expected.to have_db_column(:class_section_code).of_type(:string) }
    it { is_expected.to have_db_column(:course_credits).of_type(:string) }
    it { is_expected.to have_db_column(:current_enrollment).of_type(:integer) }
    it { is_expected.to have_db_column(:instructor_load_factor).of_type(:integer) }
    it { is_expected.to have_db_column(:instruction_mode).of_type(:string) }
    it { is_expected.to have_db_column(:instructor_role).of_type(:string) }
    it { is_expected.to have_db_column(:course_component).of_type(:string) }
    it { is_expected.to have_db_column(:xcourse_course_pre).of_type(:string) }
    it { is_expected.to have_db_column(:xcourse_course_num).of_type(:integer) }
    it { is_expected.to have_db_column(:xcourse_course_suf).of_type(:string) }
    it { is_expected.to have_db_column(:course_id).of_type(:integer) }
    it { is_expected.to have_db_column(:faculty_id).of_type(:integer) }

    it { is_expected.to have_db_index(:course_id) }
    it { is_expected.to have_db_index([:faculty_id, :course_id, :class_campus_code, :subject_code, :course_number, :course_suffix, :class_section_code, :course_component]).unique(true) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:faculty) }
    it { is_expected.to belong_to(:course) }
  end
end

