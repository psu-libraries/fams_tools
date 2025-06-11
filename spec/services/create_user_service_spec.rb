require 'rails_helper'

RSpec.describe CreateUserService do
  let(:service) { described_class.new }

  let(:csv_row) do
    CSV::Row.new(
      [
        'Last Name', 'First Name', 'Middle Name/Initial', 'Email', 'Username',
        'Penn State Health Username', 'PSU ID# (Faculty Only)', 'Authentication',
        'College', 'College_Name', 'Campus', 'Campus_Name',
        'Department', 'Division', 'School', 'Institute', 'Security'
      ],
      [
        'John', 'Smith', '', 'txt124@psu.edu', 'txt124',
        '', '123456789', 'Shibboleth',
        'UL', 'University Libraries', 'UP', 'University Park',
        'UL - Libraries Strategic Technologies', '', '', '', 'Faculty'
      ]
    )
  end
  let(:success_response) { instance_double(HTTParty::Response, parsed_response: 'Success', to_s: 'Success') }
  let(:error_response)   { instance_double(HTTParty::Response, parsed_response: 'Error: Something failed', to_s: 'Error: Something failed') }
  let(:csv_path) { Rails.root.join('app/parsing_files/upload.csv').to_s }

  before do
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_yield(csv_row)
    allow(CreateUserXmlBuilder).to receive_messages(create_user_xml: "<User PSUIDFacultyOnly='123456789' PennStateHealthUsername='' username='txt124'><FirstName>Smith</FirstName><LastName>John</LastName><Email>txt124@psu.edu</Email><ShibbolethAuthentication/></User>", insert_metadata_xml: '<INDIVIDUAL-ACTIVITIES-University><ADMIN><AC_YEAR>2025-2026</AC_YEAR><ADMIN_DEP><DEP>UL - Libraries Strategic Technologies</DEP></ADMIN_DEP><CAMPUS>UP</CAMPUS><CAMPUS_NAME>University Park</CAMPUS_NAME><COLLEGE>UL</COLLEGE><COLLEGE_NAME>University Libraries</COLLEGE_NAME><DTD_END/><DTD_START/><DTM_END/><DTM_START/><DTY_END/><DTY_START/><ENDPOS/><GRADUATE/><HR_CODE/><LEAVE/><LEAVE_OTHER/><RANK/><RESULT_SABB/><SCHOOL/><TENURE/><TIME_STATUS/><TITLE/></ADMIN></INDIVIDUAL-ACTIVITIES-University>', add_faculty_group_xml: '<INDIVIDUAL-ACTIVITIES-University-Faculty/>')
    allow(ENV).to receive(:fetch).with('FAMS_WEBSERVICES_USERNAME').and_return('fakeuser')
    allow(ENV).to receive(:fetch).with('FAMS_WEBSERVICES_PASSWORD').and_return('fakepass')
    allow(ENV).to receive(:fetch).with('FAMS_WEBSERVICES_BASE_URI', anything).and_return('https://betawebservices.digitalmeasures.com/login/service/v4')
  end

  describe '.create_user' do
    context 'when having user that is faculty' do
      it 'sends 3 XML requests per row' do
        expect(HTTParty).to receive(:post).exactly(3).times
        service.create_user
      end

      it 'logs no errors when all responses are successful' do
        allow(HTTParty).to receive(:post).and_return(success_response)
        errors = service.create_user
        expect(errors).to be_empty
      end

      it 'logs errors when response includes "Error"' do
        allow(HTTParty).to receive(:post).and_return(error_response)
        errors = service.create_user

        expect(errors).to all(include(:response))
        expect(errors.first[:response]).to include('Error:')
      end
    end

    context 'when having a user that is not faculty' do
      it 'only sends 2 POST requests' do
        allow(CreateUserXmlBuilder).to receive(:add_faculty_group_xml).and_return(nil)
        expect(HTTParty).to receive(:post).twice # user and metadata only
        service.create_user
      end

      it 'logs no errors when all responses are successful' do
        allow(HTTParty).to receive(:post).and_return(success_response)
        errors = service.create_user
        expect(errors).to be_empty
      end

      it 'logs errors when response includes "Error"' do
        allow(HTTParty).to receive(:post).and_return(error_response)
        errors = service.create_user

        expect(errors).to all(include(:response))
        expect(errors.first[:response]).to include('Error:')
      end
    end
  end
end
