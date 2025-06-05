require 'integration/integrations_helper'

describe '#create_users_integrate' do
  let!(:integration) { FactoryBot.create(:integration) }
  let(:passcode) { Rails.application.config_for(:integration_passcode)[:passcode] }

  context 'when uploading a CSV file with no errors', :js, type: :feature do
    before do
      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/User')
        .with(
          body: "<User PSUIDFacultyOnly='123456789' username='txt124'><FirstName>Smith</FirstName><LastName>John</LastName><Email>txt124@psu.edu</Email><ShibbolethAuthentication/></User>",
          headers: {
            'Content-Type' => 'application/xml'
          }
        )
        .to_return(status: 200, body: '', headers: {})

      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/UserSchema/USERNAME:txt124')
        .with(
          body: "<INDIVIDUAL-ACTIVITIES-University><ADMIN><AC_YEAR>#{Time.current.year}-#{Time.current.year + 1}</AC_YEAR><ADMIN_DEP><DEP>UL - Libraries Strategic Technologies</DEP></ADMIN_DEP><CAMPUS>UP</CAMPUS><CAMPUS_NAME>University Park</CAMPUS_NAME><COLLEGE>UL</COLLEGE><COLLEGE_NAME>University Libraries</COLLEGE_NAME><DTD_END/><DTD_START/><DTM_END/><DTM_START/><DTY_END/><DTY_START/><ENDPOS/><GRADUATE/><HR_CODE/><LEAVE/><LEAVE_OTHER/><RANK/><RESULT_SABB/><SCHOOL/><TENURE/><TIME_STATUS/><TITLE/></ADMIN></INDIVIDUAL-ACTIVITIES-University>",
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
          body: "<User PSUIDFacultyOnly='987654320' username='jad02912'><FirstName>Doe</FirstName><LastName>Jane</LastName><Email>jad02912@psu.edu</Email><ShibbolethAuthentication/></User>",
          headers: {
            'Content-Type' => 'application/xml'
          }
        )
        .to_return(status: 200, body: '', headers: {})

      stub_request(:post, 'https://betawebservices.digitalmeasures.com/login/service/v4/UserSchema/USERNAME:jad02912')
        .with(
          body: "<INDIVIDUAL-ACTIVITIES-University><ADMIN><AC_YEAR>#{Time.current.year}-#{Time.current.year + 1}</AC_YEAR><ADMIN_DEP><DEP>UL - Libraries Strategic Technologies</DEP></ADMIN_DEP><CAMPUS>UP</CAMPUS><CAMPUS_NAME>University Park</CAMPUS_NAME><COLLEGE>UL</COLLEGE><COLLEGE_NAME>University Libraries</COLLEGE_NAME><DTD_END/><DTD_START/><DTM_END/><DTM_START/><DTY_END/><DTY_START/><ENDPOS/><GRADUATE/><HR_CODE/><LEAVE/><LEAVE_OTHER/><RANK/><RESULT_SABB/><SCHOOL/><TENURE/><TIME_STATUS/><TITLE/></ADMIN></INDIVIDUAL-ACTIVITIES-University>",
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
      expect(page).to have_content('Integration completed in')
    end
  end
end
