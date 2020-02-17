require 'importers/importers_helper'

RSpec.describe ImportGpaData do
  let(:gpa_parser_obj) { ImportGpaData.new 'spec/fixtures/gpa_data.xlsx' }

  before do
    FactoryBot.create :faculty, access_id: 'abc123', college: 'LA'
    FactoryBot.create :faculty, access_id: 'def456', college: 'LA'
  end

  describe "#import" do
    it "imports data from xlsx" do
      gpa_parser_obj.import
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.semester).to eq 'Spring'
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.year).to eq 2018
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.course_prefix).to eq 'CRIM'
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.course_number).to eq '111'
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.course_number_suffix).to eq nil
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.section_number).to eq '002'
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.campus).to eq 'UP'
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.number_of_grades).to eq 38
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.course_gpa).to eq 3.16
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_a).to eq 1
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_a_minus).to eq 6
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_b_plus).to eq 13
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_b).to eq 12
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_b_minus).to eq 2
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_c_plus).to eq 4
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_c).to eq 0
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_d).to eq 0
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_f).to eq 0
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_w).to eq 0
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_ld).to eq 12
      expect(Faculty.find_by(access_id: 'abc123').gpas.first.grade_dist_other).to eq 0
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.semester).to eq 'Spring'
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.year).to eq 2018
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.course_prefix).to eq 'PSY'
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.course_number).to eq '225'
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.course_number_suffix).to eq nil
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.section_number).to eq '23'
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.campus).to eq 'UP'
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.number_of_grades).to eq 45
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.course_gpa).to eq 3.1
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_a).to eq 16
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_a_minus).to eq 4
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_b_plus).to eq 5
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_b).to eq 5
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_b_minus).to eq 7
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_c_plus).to eq 2
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_c).to eq 2
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_d).to eq 2
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_f).to eq 2
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_w).to eq 1
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_ld).to eq 4
      expect(Faculty.find_by(access_id: 'abc123').gpas.second.grade_dist_other).to eq 0
      expect(Faculty.find_by(access_id: 'def456').gpas.first.semester).to eq 'Spring'
      expect(Faculty.find_by(access_id: 'def456').gpas.first.year).to eq 2018
      expect(Faculty.find_by(access_id: 'def456').gpas.first.course_prefix).to eq 'AFAM'
      expect(Faculty.find_by(access_id: 'def456').gpas.first.course_number).to eq '102'
      expect(Faculty.find_by(access_id: 'def456').gpas.first.course_number_suffix).to eq 'C'
      expect(Faculty.find_by(access_id: 'def456').gpas.first.section_number).to eq '001'
      expect(Faculty.find_by(access_id: 'def456').gpas.first.campus).to eq 'UP'
      expect(Faculty.find_by(access_id: 'def456').gpas.first.number_of_grades).to eq 17
      expect(Faculty.find_by(access_id: 'def456').gpas.first.course_gpa).to eq 3.14
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_a).to eq 5
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_a_minus).to eq 2
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_b_plus).to eq 3
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_b).to eq 5
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_b_minus).to eq 0
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_c_plus).to eq 0
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_c).to eq 0
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_d).to eq 1
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_f).to eq 1
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_w).to eq 1
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_ld).to eq 2
      expect(Faculty.find_by(access_id: 'def456').gpas.first.grade_dist_other).to eq 0
    end
  end
end