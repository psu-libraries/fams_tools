require 'importers/importers_helper'

RSpec.describe ReturnSystemDups do

  let(:xml) do
    [
    '<?xml version="1.0" encoding="UTF-8"?>

    <Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2018-05-30">
            <Record userId="123456" username="bbb444" termId="123" dmd:surveyId="3223223">
                    <dmd:IndexEntry indexKey="CAMPUS" entryKey="UP" text="UP"/>
                    <dmd:IndexEntry indexKey="CAMPUS_NAME" entryKey="University Park" text="University Park"/>
                    <dmd:IndexEntry indexKey="COLLEGE" entryKey="EN" text="EN"/>
                    <dmd:IndexEntry indexKey="COLLEGE_NAME" entryKey="College of Engineering" text="College of Engineering"/>
                    <dmd:IndexEntry indexKey="DEPARTMENT" entryKey="EN - Aerospace Engineering" text="EN - Aerospace Engineering"/>
                    <CONGRANT id="1234121" dmd:lastModified="2018-05-29T09:05:05" dmd:primaryKey="987654">
                            <OSPKEY access="LOCKED">987654</OSPKEY>
                            <BASE_AGREE access="LOCKED"/>
                            <TYPE access="LOCKED"/>
                            <TITLE access="LOCKED">Building Automated Tests is Fun</TITLE>
                            <SPONORG access="LOCKED">Big Institution</SPONORG>
                            <AWARDORG access="LOCKED">Federal Agencies</AWARDORG>
                            <AWARDORG_OTHER/>
                            <IMPROVE_INST/>
                            <CONGRANT_INVEST id="1234566786" dmd:primaryKey="3413254|Frank|Sinatra|">
                                    <FACULTY_NAME>3413254</FACULTY_NAME>
                                    <FNAME>Frank</FNAME>
                                    <MNAME/>
                                    <LNAME>Sinatra</LNAME>
                                    <ROLE>Principal Investigator</ROLE>
                                    <ASSIGN>100</ASSIGN>
                            </CONGRANT_INVEST>
                            <AMOUNT_REQUEST access="LOCKED">1</AMOUNT_REQUEST>
                            <AMOUNT_ANTICIPATE access="LOCKED">0</AMOUNT_ANTICIPATE>
                            <AMOUNT access="LOCKED">0</AMOUNT>
                            <ABSTRACT/>
                            <COMMENT/>
                            <STATUS access="LOCKED">Not Funded</STATUS>
                            <ADD_INFO_URL/>
                            <DTM_SUB access="LOCKED">January</DTM_SUB>
                            <DTD_SUB access="LOCKED">01</DTD_SUB>
                            <DTY_SUB access="LOCKED">2012</DTY_SUB>
                            <SUB_START>2012-01-01</SUB_START>
                            <SUB_END>2012-01-01</SUB_END>
                            <DTM_AWARD/>
                            <DTD_AWARD/>
                            <DTY_AWARD/>
                            <AWARD_START></AWARD_START>
                            <AWARD_END></AWARD_END>
                            <DTM_START/>
                            <DTD_START/>
                            <DTY_START/>
                            <START_START></START_START>
                            <START_END></START_END>
                            <DTM_END/>
                            <DTD_END/>
                            <DTY_END/>
                            <END_START></END_START>
                            <END_END></END_END>
                            <USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
                    </CONGRANT>
                    <CONGRANT id="748329392" dmd:originalSource="IMPORT" dmd:lastModified="2018-05-29T09:05:05" dmd:primaryKey="987654">
                            <OSPKEY access="LOCKED">987654</OSPKEY>
                            <BASE_AGREE access="LOCKED"/>
                            <TYPE access="LOCKED"/>
                            <TITLE access="LOCKED">Building Automated Tests is Fun</TITLE>
                            <SPONORG access="LOCKED">Big Institution</SPONORG>
                            <AWARDORG access="LOCKED">Federal Agencies</AWARDORG>
                            <CONGRANT_INVEST id="4623426542" dmd:primaryKey="3413254|Frank|Sinatra|">
                                    <FACULTY_NAME>3413254</FACULTY_NAME>
                                    <FNAME>Frank</FNAME>
                                    <MNAME/>
                                    <LNAME>Sinatra</LNAME>
                                    <ROLE>Principal Investigator</ROLE>
                                    <ASSIGN>100</ASSIGN>
                            </CONGRANT_INVEST>
                            <AMOUNT_REQUEST access="LOCKED">1</AMOUNT_REQUEST>
                            <AMOUNT_ANTICIPATE access="LOCKED">0</AMOUNT_ANTICIPATE>
                            <AMOUNT access="LOCKED">0</AMOUNT>
                            <STATUS access="LOCKED">Not Funded</STATUS>
                            <DTM_SUB access="LOCKED">August</DTM_SUB>
                            <DTD_SUB access="LOCKED">01</DTD_SUB>
                            <DTY_SUB access="LOCKED">2013</DTY_SUB>
                            <SUB_START>2013-08-01</SUB_START>
                            <SUB_END>2013-08-01</SUB_END>
                            <DTM_AWARD/>
                            <DTD_AWARD/>
                            <DTY_AWARD/>
                            <AWARD_START></AWARD_START>
                            <AWARD_END></AWARD_END>
                            <DTM_START/>
                            <DTD_START/>
                            <DTY_START/>
                            <START_START></START_START>
                            <START_END></START_END>
                            <DTM_END/>
                            <DTD_END/>
                            <DTY_END/>
                            <END_START></END_START>
                            <END_END></END_END>
                            <USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
                    </CONGRANT>',

    '<?xml version="1.0" encoding="UTF-8"?>

    <Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2018-05-30">
            <Record userId="757575" username="uuu999" termId="475" dmd:surveyId="425345423">
                    <dmd:IndexEntry indexKey="CAMPUS" entryKey="UP" text="UP"/>
                    <dmd:IndexEntry indexKey="CAMPUS_NAME" entryKey="University Park" text="University Park"/>
                    <dmd:IndexEntry indexKey="COLLEGE" entryKey="EN" text="EN"/>
                    <dmd:IndexEntry indexKey="COLLEGE_NAME" entryKey="College of Engineering" text="College of Engineering"/>
                    <dmd:IndexEntry indexKey="DEPARTMENT" entryKey="EN - Aerospace Engineering" text="EN - Aerospace Engineering"/>
                    <CONGRANT id="423432465652" dmd:lastModified="2018-05-29T09:05:05" dmd:primaryKey="65463423">
                            <OSPKEY access="LOCKED">65463423</OSPKEY>
                            <BASE_AGREE access="LOCKED"/>
                            <TYPE access="LOCKED"/>
                            <TITLE access="LOCKED">Robots That Break Things</TITLE>
                            <SPONORG access="LOCKED">National Aeronautics and Space Administration</SPONORG>
                            <AWARDORG access="LOCKED">Federal Agencies</AWARDORG>
                            <AWARDORG_OTHER/>
                            <IMPROVE_INST/>
                            <CONGRANT_INVEST id="54357245" dmd:primaryKey="6543|Man|Blue|">
                                    <FACULTY_NAME>6543</FACULTY_NAME>
                                    <FNAME>Blue</FNAME>
                                    <MNAME/>
                                    <LNAME>Man</LNAME>
                                    <ROLE>Principal Investigator</ROLE>
                                    <ASSIGN>100</ASSIGN>
                            </CONGRANT_INVEST>
                            <AMOUNT_REQUEST access="LOCKED">1</AMOUNT_REQUEST>
                            <AMOUNT_ANTICIPATE access="LOCKED">0</AMOUNT_ANTICIPATE>
                            <AMOUNT access="LOCKED">0</AMOUNT>
                            <ABSTRACT/>
                            <COMMENT/>
                            <STATUS access="LOCKED">Not Funded</STATUS>
                            <ADD_INFO_URL/>
                            <DTM_SUB access="LOCKED">February</DTM_SUB>
                            <DTD_SUB access="LOCKED">09</DTD_SUB>
                            <DTY_SUB access="LOCKED">2012</DTY_SUB>
                            <SUB_START>2012-02-09</SUB_START>
                            <SUB_END>2012-02-09</SUB_END>
                            <DTM_AWARD/>
                            <DTD_AWARD/>
                            <DTY_AWARD/>
                            <AWARD_START></AWARD_START>
                            <AWARD_END></AWARD_END>
                            <DTM_START/>
                            <DTD_START/>
                            <DTY_START/>
                            <START_START></START_START>
                            <START_END></START_END>
                            <DTM_END/>
                            <DTD_END/>
                            <DTY_END/>
                            <END_START></END_START>
                            <END_END></END_END>
                            <USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
                    </CONGRANT>
                    <CONGRANT id="27384972" dmd:originalSource="IMPORT" dmd:lastModified="2018-05-29T09:05:05" dmd:primaryKey="738292">
                            <OSPKEY access="LOCKED">738292</OSPKEY>
                            <BASE_AGREE access="LOCKED"/>
                            <TYPE access="LOCKED"/>
                            <TITLE access="LOCKED">Robots That Are Cool</TITLE>
                            <SPONORG access="LOCKED">University of Cool Robots</SPONORG>
                            <AWARDORG access="LOCKED">Federal Agencies</AWARDORG>
                            <CONGRANT_INVEST id="1234321" dmd:primaryKey="6543|Man|Blue|">
                                    <FACULTY_NAME>6543</FACULTY_NAME>
                                    <FNAME>Blue</FNAME>
                                    <MNAME/>
                                    <LNAME>Man</LNAME>
                                    <ROLE>Co-Principal Investigator</ROLE>
                                    <ASSIGN>50</ASSIGN>
                            </CONGRANT_INVEST>
                            <AMOUNT_REQUEST access="LOCKED">240000</AMOUNT_REQUEST>
                            <AMOUNT_ANTICIPATE access="LOCKED">0</AMOUNT_ANTICIPATE>
                            <AMOUNT access="LOCKED">0</AMOUNT>
                            <STATUS access="LOCKED">Not Funded</STATUS>
                            <DTM_SUB access="LOCKED">August</DTM_SUB>
                            <DTD_SUB access="LOCKED">01</DTD_SUB>
                            <DTY_SUB access="LOCKED">2013</DTY_SUB>
                            <SUB_START>2013-08-01</SUB_START>
                            <SUB_END>2013-08-01</SUB_END>
                            <DTM_AWARD/>
                            <DTD_AWARD/>
                            <DTY_AWARD/>
                            <AWARD_START></AWARD_START>
                            <AWARD_END></AWARD_END>
                            <DTM_START/>
                            <DTD_START/>
                            <DTY_START/>
                            <START_START></START_START>
                            <START_END></START_END>
                            <DTM_END/>
                            <DTD_END/>
                            <DTY_END/>
                            <END_START></END_START>
                            <END_END></END_END>
                            <USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
                    </CONGRANT>'
    ]
  end

  let(:return_dups_obj) {ReturnSystemDups.allocate}

  describe "#call" do
    it "should return a list of ospkeys with duplicates" do
      return_dups_obj.responses = xml
      expect { return_dups_obj.call }.to output("bbb444\n987654\nuuu999\n").to_stdout
    end
  end

end

RSpec.describe RemoveSystemDups do
  
  let(:data_book) do
    [['GROUP', 'USERNAME', 'USER_ID', 'SURVEY_ID', 'ID', 'WEB_APPEAR', 'OSPKEY', 'BASE_AGREE', 'TYPE',
      'TITLE', 'SPONORG', 'AWARDORG', 'EXTRAMURAL', 'AWARDORG_OTHER', 'CLASSIFICATION', 'IMPROVE_INST', 
      'AMOUNT_REQUEST', 'AMOUNT_ANTICIPATE', 'AMOUNT', 'ABSTRACT', 'COMMENT', 'STATUS', 'STATUS', 'GRANT_NUM', 
      'ADD_INFO_URL', 'DTM_SUB', 'DTD_SUB', 'DTY_SUB', 'SUB_START', 'SUB_END', 'DTM_AWARD', 'DTD_AWARD', 
      'DTY_AWARD', 'AWARD_START', 'AWARD_END', 'DTM_START', 'DTD_START', 'DTY_START', 'START_START', 'START_END', 
      'DTM_END', 'DTD_END', 'DTY_END', 'END_START', 'END_END', 'USER_REFERENCE_CREATOR'],
     ['', 'xxx444', '', '', '1234567', '', '54321', '', '', 'The Societal Impact of Mock Datasets'],
     ['', 'xxx444', '', '', '2345678', '', '54321', '', '', 'The Societal Impact of Fake Datasets'],
     ['', 'yyy555', '', '', '4523133', '', '54321', '', '', 'The Societal Impact of Mock Datasets'],
     ['', 'zzz666', '', '', '9876543', '', '65432', '', '', 'Why Mock Datasets are Destroying the Country']]
  end

  let(:remove_dups_beta) {RemoveSystemDups.new(:beta)}

  describe "#call" do
    it "should identify duplicates and
        should make a request to DM to remove duplicates" do
      sponsor = Sponsor.create(sponsor_name: 'Sponsor')
      Contract.create(osp_key: 54321, sponsor: sponsor)
      allow(CSV).to receive(:foreach).and_yield(data_book[0]).and_yield(data_book[1]).and_yield(data_book[2]).and_yield(data_book[3]).and_yield(data_book[4])

      stub_request(:post, "https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-University").
         with(
           body: "<?xml version=\"1.0\"?>\n<Data>\n  <CONGRANT>\n    <item id=\"1234567\"/>\n    <item id=\"2345678\"/>\n  </CONGRANT>\n</Data>\n",
           headers: {
       	  'Content-Type'=>'text/xml'
           }).
         to_return(status: 200, body: "<?xml version=\"1.0\"?>\n<Success>\n  <item/>\n</Success>\n", headers: {})

      remove_dups_beta.call
    end
  end

end
