require 'importers/importers_helper'

RSpec.describe YearlyData::ImportYearlyData do
  let(:yearly_parser_obj) { YearlyData::ImportYearlyData.new 'spec/fixtures/yearly_data.xlsx' }

  before do
    FactoryBot.create :faculty, access_id: 'abc123', college: 'LA'
    FactoryBot.create :faculty, access_id: 'def456'
  end

  describe "#import" do
    it "imports data from xlsx" do
      yearly_parser_obj.import
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.academic_year).to eq '2023-2024'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.campus).to eq 'UP'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.campus_name).to eq 'University Park'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.college).to eq 'LA'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.college_name).to eq 'College of the Liberal Arts'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.school).to eq 'School of Liberal Arts'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.division).to eq 'Liberal Arts'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.institute).to eq 'Institute'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.admin_dept1).to eq 'LA - Philosophy'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.admin_dept1_other).to eq 'Other 1'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.admin_dept2).to eq 'LA - English'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.admin_dept2_other).to eq 'Other 2'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.admin_dept3).to eq 'LA - African American Studies'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.admin_dept3_other).to eq 'Other 3'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.title).to eq 'Associate Professor of Philosophy'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.rank).to eq 'Professor'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.tenure).to eq 'Tenured'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.endowed_position).to eq 'Associate Professor'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.graduate).to eq 'Yes'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.time_status).to eq 'Full Time'
      expect(Faculty.find_by(access_id: 'abc123').yearlies.first.hr_code).to eq 'ACT'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.academic_year).to eq '2023-2024'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.campus).to eq 'BW'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.campus_name).to eq 'Brandywine'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.college).to eq 'UC'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.college_name).to eq 'University College'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.school).to eq 'IST'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.division).to eq 'UC - Information Sciences and Technology'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.institute).to eq 'Institute'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.admin_dept1).to eq 'UC - IST'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.admin_dept1_other).to be_nil
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.admin_dept2).to eq 'UC - Mathematics'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.admin_dept2_other).to be_nil
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.admin_dept3).to eq 'UC - Engineering'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.admin_dept3_other).to be_nil
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.title).to eq 'Assistant Professor of IST'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.rank).to eq 'Assistant Teaching Professor'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.tenure).to eq 'Non-Tenure Track'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.endowed_position).to eq 'Assistant Professor'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.graduate).to eq 'No'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.time_status).to eq 'Part Time'
      expect(Faculty.find_by(access_id: 'def456').yearlies.first.hr_code).to be_nil

    end
  end
end