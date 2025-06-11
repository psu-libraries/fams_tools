require 'rails_helper'

RSpec.describe CreateUserXmlBuilder do
  describe '.create_user_xml' do
    let(:user) do
      CSV::Row.new(['Last Name',	'First Name',	'Middle Name/Initial',	'Email',	'Username',	'PSU ID# (Faculty Only)',	'Authentication'],
                   ['John', 'Smith', '', 'txt124@psu.edu', 'txt124', '123456789', 'Shibboleth'])
    end

    context 'when creating a user' do
      it 'generates an xml' do
        output = CreateUserXmlBuilder.create_user_xml(user)
        expect(output).to eq("<User PSUIDFacultyOnly='123456789' PennStateHealthUsername='' username='txt124'><FirstName>Smith</FirstName><LastName>John</LastName><Email>txt124@psu.edu</Email><ShibbolethAuthentication/></User>")
      end
    end
  end

  describe '.insert_metadata_xml' do
    let(:metadata) do
      CSV::Row.new(['Academic Year', 'College', 'College_Name', 'Campus', 'Campus_Name', 'Department', 'Division', 'School', 'Institute', 'Title', 'Rank', 'Tenure'],
                   ['2025-2026', 'UL',	'University Libraries',	'UP',	'University Park',	'UL - Libraries Strategic Technologies',	'', '', '', '', '', ''])
    end

    context 'when extracting metadata from a CSV' do
      it 'generates an xml for user attributes' do
        output = CreateUserXmlBuilder.insert_metadata_xml(metadata)
        expect(output).to eq('<INDIVIDUAL-ACTIVITIES-University><ADMIN><AC_YEAR>2025-2026</AC_YEAR><ADMIN_DEP><DEP>UL - Libraries Strategic Technologies</DEP></ADMIN_DEP><CAMPUS>UP</CAMPUS><CAMPUS_NAME>University Park</CAMPUS_NAME><COLLEGE>UL</COLLEGE><COLLEGE_NAME>University Libraries</COLLEGE_NAME><DIVISION></DIVISION><DTD_END/><DTD_START/><DTM_END/><DTM_START/><DTY_END/><DTY_START/><ENDPOS/><GRADUATE/><HR_CODE/><INSTITUTE></INSTITUTE><LEAVE/><LEAVE_OTHER/><RANK></RANK><RESULT_SABB/><SCHOOL/><TENURE></TENURE><TIME_STATUS/><TITLE></TITLE></ADMIN></INDIVIDUAL-ACTIVITIES-University>')
      end
    end
  end

  describe '.add_faculty_group_xml' do
    let(:faculty_row) { CSV::Row.new(['Security'], ['Faculty']) }
    let(:non_faculty_row) { CSV::Row.new(['Security'], ['']) }

    context 'when user is a faculty member' do
      it 'outputs an xml for adding the faculty role' do
        output = CreateUserXmlBuilder.add_faculty_group_xml(faculty_row)
        expect(output).to eq('<INDIVIDUAL-ACTIVITIES-University-Faculty/>')
      end
    end

    context 'when user is not a faculty member' do
      it 'outputs nil' do
        output = CreateUserXmlBuilder.add_faculty_group_xml(non_faculty_row)
        expect(output).to be_nil
      end
    end
  end
end
