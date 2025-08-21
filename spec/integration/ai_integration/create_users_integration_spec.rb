require 'integration/integrations_helper'

describe '#create_users_integrate' do
  let!(:integration) { FactoryBot.create(:integration) }
  let(:passcode) { Rails.application.config_for(:integration_passcode)[:passcode] }

  context 'when uploading a CSV file with no errors', :js, type: :feature do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('FAMS_WEBSERVICES_BASE_URI', anything).and_return('https://betawebservices.digitalmeasures.com/login/service/v4')

      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/User')
        .with(
          body: "<User PSUIDFacultyOnly='123456789' PennStateHealthUsername='' username='txt124'><FirstName>Smith</FirstName><LastName>John</LastName><Email>txt124@psu.edu</Email><ShibbolethAuthentication/></User>",
          headers: {
            'Content-Type' => 'application/xml'
          }
        )
        .to_return(status: 200, body: '', headers: {})

      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/UserSchema/USERNAME:txt124')
        .with(
          body: '<INDIVIDUAL-ACTIVITIES-University><ADMIN><AC_YEAR>2025-2026</AC_YEAR><ADMIN_DEP><DEP>UL - Libraries Strategic Technologies</DEP></ADMIN_DEP><CAMPUS>UP</CAMPUS><CAMPUS_NAME>University Park</CAMPUS_NAME><COLLEGE>UL</COLLEGE><COLLEGE_NAME>University Libraries</COLLEGE_NAME><DIVISION></DIVISION><DTD_END/><DTD_START/><DTM_END/><DTM_START/><DTY_END/><DTY_START/><ENDPOS/><GRADUATE/><HR_CODE/><INSTITUTE></INSTITUTE><LEAVE/><LEAVE_OTHER/><RANK></RANK><RESULT_SABB/><SCHOOL/><TENURE></TENURE><TIME_STATUS/><TITLE></TITLE></ADMIN></INDIVIDUAL-ACTIVITIES-University>',
          headers: {
            'Content-Type' => 'application/xml'
          }
        )
        .to_return(status: 200, body: '', headers: {})

      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/UserRole/USERNAME:txt124')
        .with(
          body: '<INDIVIDUAL-ACTIVITIES-University-Faculty/>',
          headers: {
            'Content-Type' => 'application/xml'
          }
        )
        .to_return(status: 200, body: '', headers: {})

      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/User')
        .with(
          body: "<User PSUIDFacultyOnly='987654320' PennStateHealthUsername='' username='jad02912'><FirstName>Doe</FirstName><LastName>Jane</LastName><Email>jad02912@psu.edu</Email><ShibbolethAuthentication/></User>",
          headers: {
            'Content-Type' => 'application/xml'
          }
        )
        .to_return(status: 200, body: '', headers: {})

      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/UserSchema/USERNAME:jad02912')
        .with(
          body: '<INDIVIDUAL-ACTIVITIES-University><ADMIN><AC_YEAR>2025-2026</AC_YEAR><ADMIN_DEP><DEP>UL - Libraries Strategic Technologies</DEP></ADMIN_DEP><CAMPUS>UP</CAMPUS><CAMPUS_NAME>University Park</CAMPUS_NAME><COLLEGE>UL</COLLEGE><COLLEGE_NAME>University Libraries</COLLEGE_NAME><DIVISION></DIVISION><DTD_END/><DTD_START/><DTM_END/><DTM_START/><DTY_END/><DTY_START/><ENDPOS/><GRADUATE/><HR_CODE/><INSTITUTE></INSTITUTE><LEAVE/><LEAVE_OTHER/><RANK></RANK><RESULT_SABB/><SCHOOL/><TENURE></TENURE><TIME_STATUS/><TITLE></TITLE></ADMIN></INDIVIDUAL-ACTIVITIES-University>',
          headers: {
            'Content-Type' => 'application/xml'
          }
        )
        .to_return(status: 200, body: '', headers: {})

      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/UserRole/USERNAME:jad02912')
        .with(
          body: '<INDIVIDUAL-ACTIVITIES-University-Faculty/>',
          headers: {
            'Content-Type' => 'application/xml'
          }
        )
        .to_return(status: 200, body: '', headers: {})
    end

    it 'successfully completes integration' do
      visit ai_integration_path
      expect(page).to have_content('AI-Integration')
      select('Create Users Integration', from: 'label_integration_type').select_option
      within('#create_users') do
        page.attach_file 'create_users_file', Rails.root.join('spec/fixtures/create_user.csv')
        page.fill_in 'passcode', with: passcode
        page.accept_alert 'Are you sure you want to integrate into beta?' do
          click_on 'Beta'
        end
      end
      expect(page).to have_content('Integration added to queue.')
    end
  end
end
