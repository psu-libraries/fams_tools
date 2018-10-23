require 'rails_helper'

RSpec.describe AiIntegrationController do

  before :each do 
    @users = fixture_file_upload('spec/fixtures/users.xls')
    @contract_grants = fixture_file_upload('spec/fixtures/contract_grants.xlsx')
    @congrant_backup = fixture_file_upload('spec/fixtures/congrant_backup.txt')
  end

  it "runs integration of contract/grants" do
    params = { psu_users_file: @users, congrant_file: @contract_grants, ai_backup_file: @congrant_backup, "target" => :beta }

    stub_request(:post, "https://beta.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University").
         with(
           body: body,
           headers: {
       	  'Content-Type'=>'text/xml'
           }).
         to_return(status: 200, body: "", headers: {})

    post ai_integration_osp_integrate_path, params: params
  end

  def body
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ljs123\">\n    <CONGRANT>\n      <OSPKEY access=\"READ_ONLY\">54321</OSPKEY>\n      <BASE_AGREE access=\"READ_ONLY\"/>\n      <TYPE access=\"READ_ONLY\"/>\n      <TITLE access=\"READ_ONLY\">Title 2</TITLE>\n      <SPONORG access=\"READ_ONLY\">Some Other Sponsor</SPONORG>\n      <AWARDORG access=\"READ_ONLY\">Federal Agencies</AWARDORG>\n      <CONGRANT_INVEST>\n        <FACULTY_NAME>123456</FACULTY_NAME>\n        <FNAME>Larry</FNAME>\n        <MNAME/>\n        <LNAME>Smith</LNAME>\n        <ROLE>Co-Principal Investigator</ROLE>\n        <ASSIGN>50</ASSIGN>\n      </CONGRANT_INVEST>\n      <AMOUNT_REQUEST access=\"READ_ONLY\">25</AMOUNT_REQUEST>\n      <AMOUNT_ANTICIPATE access=\"READ_ONLY\">4</AMOUNT_ANTICIPATE>\n      <AMOUNT access=\"READ_ONLY\">3</AMOUNT>\n      <STATUS access=\"READ_ONLY\">Awarded</STATUS>\n      <DTM_SUB access=\"READ_ONLY\">December</DTM_SUB>\n      <DTD_SUB access=\"READ_ONLY\">14</DTD_SUB>\n      <DTY_SUB access=\"READ_ONLY\">2015</DTY_SUB>\n      <DTM_AWARD/>\n      <DTD_AWARD/>\n      <DTY_AWARD/>\n      <DTM_START access=\"READ_ONLY\">June</DTM_START>\n      <DTD_START access=\"READ_ONLY\">01</DTD_START>\n      <DTY_START access=\"READ_ONLY\">2015</DTY_START>\n      <DTM_END access=\"READ_ONLY\">May</DTM_END>\n      <DTD_END access=\"READ_ONLY\">31</DTD_END>\n      <DTY_END access=\"READ_ONLY\">2015</DTY_END>\n      <DTM_DECLINE/>\n      <DTD_DECLINE/>\n      <DTY_DECLINE/>\n    </CONGRANT>\n  </Record>\n  <Record username=\"ajl123\">\n    <CONGRANT>\n      <OSPKEY access=\"READ_ONLY\">12345</OSPKEY>\n      <BASE_AGREE access=\"READ_ONLY\"/>\n      <TYPE access=\"READ_ONLY\"/>\n      <TITLE access=\"READ_ONLY\">Title 1</TITLE>\n      <SPONORG access=\"READ_ONLY\">Some Sponsor</SPONORG>\n      <AWARDORG access=\"READ_ONLY\">Federal Agencies</AWARDORG>\n      <CONGRANT_INVEST>\n        <FACULTY_NAME>345678</FACULTY_NAME>\n        <FNAME>Abraham</FNAME>\n        <MNAME/>\n        <LNAME>Lincoln</LNAME>\n        <ROLE>Principal Investigator</ROLE>\n        <ASSIGN>100</ASSIGN>\n      </CONGRANT_INVEST>\n      <AMOUNT_REQUEST access=\"READ_ONLY\">10000</AMOUNT_REQUEST>\n      <AMOUNT_ANTICIPATE access=\"READ_ONLY\">10</AMOUNT_ANTICIPATE>\n      <AMOUNT access=\"READ_ONLY\">1</AMOUNT>\n      <STATUS access=\"READ_ONLY\">Awarded</STATUS>\n      <DTM_SUB access=\"READ_ONLY\">November</DTM_SUB>\n      <DTD_SUB access=\"READ_ONLY\">15</DTD_SUB>\n      <DTY_SUB access=\"READ_ONLY\">2015</DTY_SUB>\n      <DTM_AWARD/>\n      <DTD_AWARD/>\n      <DTY_AWARD/>\n      <DTM_START access=\"READ_ONLY\">January</DTM_START>\n      <DTD_START access=\"READ_ONLY\">01</DTD_START>\n      <DTY_START access=\"READ_ONLY\">2015</DTY_START>\n      <DTM_END access=\"READ_ONLY\">December</DTM_END>\n      <DTD_END access=\"READ_ONLY\">31</DTD_END>\n      <DTY_END access=\"READ_ONLY\">2015</DTY_END>\n      <DTM_DECLINE/>\n      <DTD_DECLINE/>\n      <DTY_DECLINE/>\n    </CONGRANT>\n  </Record>\n</Data>\n"
  end

end
