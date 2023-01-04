require 'importers/importers_helper'

RSpec.describe ActivityInsight::IntegrateData do

  let(:xml_arr) do
    return [
'<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="aaa111">
    <CONGRANT>
      <OSPKEY access="LOCKED">123456</OSPKEY>
      <BASE_AGREE access="LOCKED"/>
      <TYPE access="LOCKED"/>
      <TITLE access="LOCKED">Title</TITLE>
      <SPONORG access="LOCKED">Sponsor</SPONORG>
      <AWARDORG access="LOCKED">Big Sponsor</AWARDORG>
      <CONGRANT_INVEST>
        <FACULTY_NAME>123</FACULTY_NAME>
        <FNAME>Bill</FNAME>
        <MNAME>Billiam</MNAME>
        <LNAME>Billy</LNAME>
        <ROLE>Principal Investigator</ROLE>
        <ASSIGN>100</ASSIGN>
      </CONGRANT_INVEST>
      <AMOUNT_REQUEST access="LOCKED">1000</AMOUNT_REQUEST>
      <AMOUNT_ANTICIPATE access="LOCKED"/>
      <AMOUNT access="LOCKED"/>
      <STATUS access="LOCKED">Pending</STATUS>
      <DTM_SUB access="LOCKED">January</DTM_SUB>
      <DTD_SUB access="LOCKED">01</DTD_SUB>
      <DTY_SUB access="LOCKED">2016</DTY_SUB>
      <DTM_AWARD/>
      <DTD_AWARD/>
      <DTY_AWARD/>
      <DTM_START/>
      <DTD_START/>
      <DTY_START/>
      <DTM_END/>
      <DTD_END/>
      <DTY_END/>
    </CONGRANT>
  </Record>
  <Record username="bbb222">
    <CONGRANT>
      <OSPKEY access="LOCKED">654321</OSPKEY>
      <BASE_AGREE access="LOCKED"/>
      <TYPE access="LOCKED"/>
      <TITLE access="LOCKED">Title</TITLE>
      <SPONORG access="LOCKED">Sponsor2</SPONORG>
      <AWARDORG access="LOCKED">Big Sponsor</AWARDORG>
      <CONGRANT_INVEST>
        <FACULTY_NAME>321</FACULTY_NAME>
        <FNAME>Bill</FNAME>
        <MNAME>Billiam</MNAME>
        <LNAME>Billy</LNAME>
        <ROLE>Principal Investigator</ROLE>
        <ASSIGN>100</ASSIGN>
      </CONGRANT_INVEST>
      <AMOUNT_REQUEST access="LOCKED">1000</AMOUNT_REQUEST>
      <AMOUNT_ANTICIPATE access="LOCKED"/>
      <AMOUNT access="LOCKED"/>
      <STATUS access="LOCKED">Pending</STATUS>
      <DTM_SUB access="LOCKED">January</DTM_SUB>
      <DTD_SUB access="LOCKED">01</DTD_SUB>
      <DTY_SUB access="LOCKED">2016</DTY_SUB>
      <DTM_AWARD/>
      <DTD_AWARD/>
      <DTY_AWARD/>
      <DTM_START/>
      <DTD_START/>
      <DTY_START/>
      <DTM_END/>
      <DTD_END/>
      <DTY_END/>
    </CONGRANT>
  </Record>
</Data>
',
'<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="ccc111">
    <CONGRANT>
      <OSPKEY access="LOCKED">315235</OSPKEY>
      <BASE_AGREE access="LOCKED"/>
      <TYPE access="LOCKED"/>
      <TITLE access="LOCKED">Title</TITLE>
      <SPONORG access="LOCKED">Sponsor</SPONORG>
      <AWARDORG access="LOCKED">Big Sponsor</AWARDORG>
      <CONGRANT_INVEST>
        <FACULTY_NAME>123</FACULTY_NAME>
        <FNAME>Greg</FNAME>
        <MNAME>Gregory</MNAME>
        <LNAME>Gregantha</LNAME>
        <ROLE>Principal Investigator</ROLE>
        <ASSIGN>100</ASSIGN>
      </CONGRANT_INVEST>
      <AMOUNT_REQUEST access="LOCKED">1000</AMOUNT_REQUEST>
      <AMOUNT_ANTICIPATE access="LOCKED"/>
      <AMOUNT access="LOCKED"/>
      <STATUS access="LOCKED">Pending</STATUS>
      <DTM_SUB access="LOCKED">January</DTM_SUB>
      <DTD_SUB access="LOCKED">01</DTD_SUB>
      <DTY_SUB access="LOCKED">2016</DTY_SUB>
      <DTM_AWARD/>
      <DTD_AWARD/>
      <DTY_AWARD/>
      <DTM_START/>
      <DTD_START/>
      <DTY_START/>
      <DTM_END/>
      <DTD_END/>
      <DTY_END/>
    </CONGRANT>
  </Record>
  <Record username="ttt222">
    <CONGRANT>
      <OSPKEY access="LOCKED">654572</OSPKEY>
      <BASE_AGREE access="LOCKED"/>
      <TYPE access="LOCKED"/>
      <TITLE access="LOCKED">Title</TITLE>
      <SPONORG access="LOCKED">Sponsor2</SPONORG>
      <AWARDORG access="LOCKED">Big Sponsor</AWARDORG>
      <CONGRANT_INVEST>
        <FACULTY_NAME>321</FACULTY_NAME>
        <FNAME>Kenneth</FNAME>
        <MNAME>Kenny</MNAME>
        <LNAME>Ken</LNAME>
        <ROLE>Principal Investigator</ROLE>
        <ASSIGN>100</ASSIGN>
      </CONGRANT_INVEST>
      <AMOUNT_REQUEST access="LOCKED">1000</AMOUNT_REQUEST>
      <AMOUNT_ANTICIPATE access="LOCKED"/>
      <AMOUNT access="LOCKED"/>
      <STATUS access="LOCKED">Pending</STATUS>
      <DTM_SUB access="LOCKED">January</DTM_SUB>
      <DTD_SUB access="LOCKED">01</DTD_SUB>
      <DTY_SUB access="LOCKED">2016</DTY_SUB>
      <DTM_AWARD/>
      <DTD_AWARD/>
      <DTY_AWARD/>
      <DTM_START/>
      <DTD_START/>
      <DTY_START/>
      <DTM_END/>
      <DTD_END/>
      <DTY_END/>
    </CONGRANT>
  </Record>
</Data>
'
      ]
  end

  describe '#integrate' do
    it 'sends a POST request to DM Beta Webservices' do
      osp_integrate_obj = ActivityInsight::IntegrateData.new(xml_arr, :beta, :post)
      osp_integrate_obj.auth = {:username => 'Username', :password => 'Password'}
      stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
         with(
           body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"aaa111\">\n    <CONGRANT>\n      <OSPKEY access=\"LOCKED\">123456</OSPKEY>\n      <BASE_AGREE access=\"LOCKED\"/>\n      <TYPE access=\"LOCKED\"/>\n      <TITLE access=\"LOCKED\">Title</TITLE>\n      <SPONORG access=\"LOCKED\">Sponsor</SPONORG>\n      <AWARDORG access=\"LOCKED\">Big Sponsor</AWARDORG>\n      <CONGRANT_INVEST>\n        <FACULTY_NAME>123</FACULTY_NAME>\n        <FNAME>Bill</FNAME>\n        <MNAME>Billiam</MNAME>\n        <LNAME>Billy</LNAME>\n        <ROLE>Principal Investigator</ROLE>\n        <ASSIGN>100</ASSIGN>\n      </CONGRANT_INVEST>\n      <AMOUNT_REQUEST access=\"LOCKED\">1000</AMOUNT_REQUEST>\n      <AMOUNT_ANTICIPATE access=\"LOCKED\"/>\n      <AMOUNT access=\"LOCKED\"/>\n      <STATUS access=\"LOCKED\">Pending</STATUS>\n      <DTM_SUB access=\"LOCKED\">January</DTM_SUB>\n      <DTD_SUB access=\"LOCKED\">01</DTD_SUB>\n      <DTY_SUB access=\"LOCKED\">2016</DTY_SUB>\n      <DTM_AWARD/>\n      <DTD_AWARD/>\n      <DTY_AWARD/>\n      <DTM_START/>\n      <DTD_START/>\n      <DTY_START/>\n      <DTM_END/>\n      <DTD_END/>\n      <DTY_END/>\n    </CONGRANT>\n  </Record>\n  <Record username=\"bbb222\">\n    <CONGRANT>\n      <OSPKEY access=\"LOCKED\">654321</OSPKEY>\n      <BASE_AGREE access=\"LOCKED\"/>\n      <TYPE access=\"LOCKED\"/>\n      <TITLE access=\"LOCKED\">Title</TITLE>\n      <SPONORG access=\"LOCKED\">Sponsor2</SPONORG>\n      <AWARDORG access=\"LOCKED\">Big Sponsor</AWARDORG>\n      <CONGRANT_INVEST>\n        <FACULTY_NAME>321</FACULTY_NAME>\n        <FNAME>Bill</FNAME>\n        <MNAME>Billiam</MNAME>\n        <LNAME>Billy</LNAME>\n        <ROLE>Principal Investigator</ROLE>\n        <ASSIGN>100</ASSIGN>\n      </CONGRANT_INVEST>\n      <AMOUNT_REQUEST access=\"LOCKED\">1000</AMOUNT_REQUEST>\n      <AMOUNT_ANTICIPATE access=\"LOCKED\"/>\n      <AMOUNT access=\"LOCKED\"/>\n      <STATUS access=\"LOCKED\">Pending</STATUS>\n      <DTM_SUB access=\"LOCKED\">January</DTM_SUB>\n      <DTD_SUB access=\"LOCKED\">01</DTD_SUB>\n      <DTY_SUB access=\"LOCKED\">2016</DTY_SUB>\n      <DTM_AWARD/>\n      <DTD_AWARD/>\n      <DTY_AWARD/>\n      <DTM_START/>\n      <DTD_START/>\n      <DTY_START/>\n      <DTM_END/>\n      <DTD_END/>\n      <DTY_END/>\n    </CONGRANT>\n  </Record>\n</Data>\n",
           headers: {
       	  'Content-Type'=>'text/xml'
           }).to_return(status: 200, body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>

<Success/>", headers: {})
      stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
         with(
           body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ccc111\">\n    <CONGRANT>\n      <OSPKEY access=\"LOCKED\">315235</OSPKEY>\n      <BASE_AGREE access=\"LOCKED\"/>\n      <TYPE access=\"LOCKED\"/>\n      <TITLE access=\"LOCKED\">Title</TITLE>\n      <SPONORG access=\"LOCKED\">Sponsor</SPONORG>\n      <AWARDORG access=\"LOCKED\">Big Sponsor</AWARDORG>\n      <CONGRANT_INVEST>\n        <FACULTY_NAME>123</FACULTY_NAME>\n        <FNAME>Greg</FNAME>\n        <MNAME>Gregory</MNAME>\n        <LNAME>Gregantha</LNAME>\n        <ROLE>Principal Investigator</ROLE>\n        <ASSIGN>100</ASSIGN>\n      </CONGRANT_INVEST>\n      <AMOUNT_REQUEST access=\"LOCKED\">1000</AMOUNT_REQUEST>\n      <AMOUNT_ANTICIPATE access=\"LOCKED\"/>\n      <AMOUNT access=\"LOCKED\"/>\n      <STATUS access=\"LOCKED\">Pending</STATUS>\n      <DTM_SUB access=\"LOCKED\">January</DTM_SUB>\n      <DTD_SUB access=\"LOCKED\">01</DTD_SUB>\n      <DTY_SUB access=\"LOCKED\">2016</DTY_SUB>\n      <DTM_AWARD/>\n      <DTD_AWARD/>\n      <DTY_AWARD/>\n      <DTM_START/>\n      <DTD_START/>\n      <DTY_START/>\n      <DTM_END/>\n      <DTD_END/>\n      <DTY_END/>\n    </CONGRANT>\n  </Record>\n  <Record username=\"ttt222\">\n    <CONGRANT>\n      <OSPKEY access=\"LOCKED\">654572</OSPKEY>\n      <BASE_AGREE access=\"LOCKED\"/>\n      <TYPE access=\"LOCKED\"/>\n      <TITLE access=\"LOCKED\">Title</TITLE>\n      <SPONORG access=\"LOCKED\">Sponsor2</SPONORG>\n      <AWARDORG access=\"LOCKED\">Big Sponsor</AWARDORG>\n      <CONGRANT_INVEST>\n        <FACULTY_NAME>321</FACULTY_NAME>\n        <FNAME>Kenneth</FNAME>\n        <MNAME>Kenny</MNAME>\n        <LNAME>Ken</LNAME>\n        <ROLE>Principal Investigator</ROLE>\n        <ASSIGN>100</ASSIGN>\n      </CONGRANT_INVEST>\n      <AMOUNT_REQUEST access=\"LOCKED\">1000</AMOUNT_REQUEST>\n      <AMOUNT_ANTICIPATE access=\"LOCKED\"/>\n      <AMOUNT access=\"LOCKED\"/>\n      <STATUS access=\"LOCKED\">Pending</STATUS>\n      <DTM_SUB access=\"LOCKED\">January</DTM_SUB>\n      <DTD_SUB access=\"LOCKED\">01</DTD_SUB>\n      <DTY_SUB access=\"LOCKED\">2016</DTY_SUB>\n      <DTM_AWARD/>\n      <DTD_AWARD/>\n      <DTY_AWARD/>\n      <DTM_START/>\n      <DTD_START/>\n      <DTY_START/>\n      <DTM_END/>\n      <DTD_END/>\n      <DTY_END/>\n    </CONGRANT>\n  </Record>\n</Data>\n",
           headers: {
       	  'Content-Type'=>'text/xml'
           }).
         to_return(status: 200, body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>

<Error>The following errors were detected:
  <Message>Unexpected EOF in prolog at [row,col {unknown-source}]: [2,0] Nested exception: Unexpected EOF in prolog at [row,col {unknown-source}]: [2,0]</Message>
</Error>", headers: {})
      expect(osp_integrate_obj.integrate).to eq(error_output)
    end
  end

  context 'when passing :delete to the third param' do
    it 'uses delete resource url' do
      integrate_data = ActivityInsight::IntegrateData.new(xml_arr, :beta, :delete)
      expect(integrate_data.send(:url)).to eq 'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University'
    end
  end

  def error_output
    [{:affected_faculty=>["ccc111", "ttt222"], :affected_osps=>["315235", "654572"], :response=>"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<Error>The following errors were detected:\n  <Message>Unexpected EOF in prolog at [row,col {unknown-source}]: [2,0] Nested exception: Unexpected EOF in prolog at [row,col {unknown-source}]: [2,0]</Message>\n</Error>"}]
  end
end
