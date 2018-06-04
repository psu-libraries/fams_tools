require 'rails_helper'
require 'lionpath_data/lionpath_integrate'

RSpec.describe LionPathIntegrate do

  let(:xml_arr) do
    return [
'<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="abc123">
    <SCHTEACH>
      <TYT_TERM access="LOCKED">Spring</TYT_TERM>
      <TYY_TERM access="LOCKED">2018</TYY_TERM>
      <TITLE access="LOCKED">The Class</TITLE>
      <DESC access="LOCKED">This is the class that a teacher teaches.</DESC>
      <COURSEPRE access="LOCKED">MGMT</COURSEPRE>
      <COURSENUM access="LOCKED">110</COURSENUM>
      <COURSENUM_SUFFIX access="LOCKED">B</COURSENUM_SUFFIX>
      <SECTION access="LOCKED">001</SECTION>
      <CAMPUS access="LOCKED">UP</CAMPUS>
      <ENROLL access="LOCKED">100</ENROLL>
      <XCOURSE_COURSEPRE access="LOCKED"/>
      <XCOURSE_COURSENUM access="LOCKED"/>
      <XCOURSE_COURSENUM_SUFFIX access="LOCKED"/>
      <RESPON access="LOCKED">100</RESPON>
      <CHOURS access="LOCKED">3</CHOURS>
      <INST_MODE access="LOCKED">In Person</INST_MODE>
      <COURSE_COMP access="LOCKED">Lecture</COURSE_COMP>
    </SCHTEACH>
  </Record>
  <Record username="cba321">
    <SCHTEACH>
      <TYT_TERM access="LOCKED">Spring</TYT_TERM>
      <TYY_TERM access="LOCKED">2018</TYY_TERM>
      <TITLE access="LOCKED">The Other Class</TITLE>
      <DESC access="LOCKED">This is the class that students learn in.</DESC>
      <COURSEPRE access="LOCKED">HIST</COURSEPRE>
      <COURSENUM access="LOCKED">100</COURSENUM>
      <COURSENUM_SUFFIX access="LOCKED">A</COURSENUM_SUFFIX>
      <SECTION access="LOCKED">002</SECTION>
      <CAMPUS access="LOCKED">UP</CAMPUS>
      <ENROLL access="LOCKED">50</ENROLL>
      <XCOURSE_COURSEPRE access="LOCKED"/>
      <XCOURSE_COURSENUM access="LOCKED"/>
      <XCOURSE_COURSENUM_SUFFIX access="LOCKED"/>
      <RESPON access="LOCKED">100</RESPON>
      <CHOURS access="LOCKED">3</CHOURS>
      <INST_MODE access="LOCKED">In Person</INST_MODE>
      <COURSE_COMP access="LOCKED">Lecture</COURSE_COMP>
    </SCHTEACH>
  </Record>
</Data>
',
'<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="ghi123">
    <SCHTEACH>
      <TYT_TERM access="LOCKED">Spring</TYT_TERM>
      <TYY_TERM access="LOCKED">2018</TYY_TERM>
      <TITLE access="LOCKED">The Class</TITLE>
      <DESC access="LOCKED">This is the class that a teacher teaches.</DESC>
      <COURSEPRE access="LOCKED">BIO</COURSEPRE>
      <COURSENUM access="LOCKED">110</COURSENUM>
      <COURSENUM_SUFFIX access="LOCKED">B</COURSENUM_SUFFIX>
      <SECTION access="LOCKED">001</SECTION>
      <CAMPUS access="LOCKED">UP</CAMPUS>
      <ENROLL access="LOCKED">100</ENROLL>
      <XCOURSE_COURSEPRE access="LOCKED"/>
      <XCOURSE_COURSENUM access="LOCKED"/>
      <XCOURSE_COURSENUM_SUFFIX access="LOCKED"/>
      <RESPON access="LOCKED">100</RESPON>
      <CHOURS access="LOCKED">3</CHOURS>
      <INST_MODE access="LOCKED">In Person</INST_MODE>
      <COURSE_COMP access="LOCKED">Lecture</COURSE_COMP>
    </SCHTEACH>
  </Record>
  <Record username="xxx321">
    <SCHTEACH>
      <TYT_TERM access="LOCKED">Spring</TYT_TERM>
      <TYY_TERM access="LOCKED">2018</TYY_TERM>
      <TITLE access="LOCKED">The Other Class</TITLE>
      <DESC access="LOCKED">This is the class that students learn in.</DESC>
      <COURSEPRE access="LOCKED">AERSP</COURSEPRE>
      <COURSENUM access="LOCKED">100</COURSENUM>
      <COURSENUM_SUFFIX access="LOCKED">A</COURSENUM_SUFFIX>
      <SECTION access="LOCKED">002</SECTION>
      <CAMPUS access="LOCKED">UP</CAMPUS>
      <ENROLL access="LOCKED">50</ENROLL>
      <XCOURSE_COURSEPRE access="LOCKED"/>
      <XCOURSE_COURSENUM access="LOCKED"/>
      <XCOURSE_COURSENUM_SUFFIX access="LOCKED"/>
      <RESPON access="LOCKED">100</RESPON>
      <CHOURS access="LOCKED">3</CHOURS>
      <INST_MODE access="LOCKED">In Person</INST_MODE>
      <COURSE_COMP access="LOCKED">Lecture</COURSE_COMP>
    </SCHTEACH>
  </Record>
</Data>
'
      ]
  end

  let(:lionpath_integrate_obj) {LionPathIntegrate.allocate}

  before do
    allow(STDOUT).to receive(:puts)
  end

  describe '#integrate' do
    it 'should send a POST request to DM Webservices' do
      lionpath_integrate_obj.lionpath_batches = xml_arr
      lionpath_integrate_obj.url = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
      lionpath_integrate_obj.auth = {:username => 'Username', :password => 'Password'}
      stub_request(:post, "https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
         with(
           body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"abc123\">\n    <SCHTEACH>\n      <TYT_TERM access=\"LOCKED\">Spring</TYT_TERM>\n      <TYY_TERM access=\"LOCKED\">2018</TYY_TERM>\n      <TITLE access=\"LOCKED\">The Class</TITLE>\n      <DESC access=\"LOCKED\">This is the class that a teacher teaches.</DESC>\n      <COURSEPRE access=\"LOCKED\">MGMT</COURSEPRE>\n      <COURSENUM access=\"LOCKED\">110</COURSENUM>\n      <COURSENUM_SUFFIX access=\"LOCKED\">B</COURSENUM_SUFFIX>\n      <SECTION access=\"LOCKED\">001</SECTION>\n      <CAMPUS access=\"LOCKED\">UP</CAMPUS>\n      <ENROLL access=\"LOCKED\">100</ENROLL>\n      <XCOURSE_COURSEPRE access=\"LOCKED\"/>\n      <XCOURSE_COURSENUM access=\"LOCKED\"/>\n      <XCOURSE_COURSENUM_SUFFIX access=\"LOCKED\"/>\n      <RESPON access=\"LOCKED\">100</RESPON>\n      <CHOURS access=\"LOCKED\">3</CHOURS>\n      <INST_MODE access=\"LOCKED\">In Person</INST_MODE>\n      <COURSE_COMP access=\"LOCKED\">Lecture</COURSE_COMP>\n    </SCHTEACH>\n  </Record>\n  <Record username=\"cba321\">\n    <SCHTEACH>\n      <TYT_TERM access=\"LOCKED\">Spring</TYT_TERM>\n      <TYY_TERM access=\"LOCKED\">2018</TYY_TERM>\n      <TITLE access=\"LOCKED\">The Other Class</TITLE>\n      <DESC access=\"LOCKED\">This is the class that students learn in.</DESC>\n      <COURSEPRE access=\"LOCKED\">HIST</COURSEPRE>\n      <COURSENUM access=\"LOCKED\">100</COURSENUM>\n      <COURSENUM_SUFFIX access=\"LOCKED\">A</COURSENUM_SUFFIX>\n      <SECTION access=\"LOCKED\">002</SECTION>\n      <CAMPUS access=\"LOCKED\">UP</CAMPUS>\n      <ENROLL access=\"LOCKED\">50</ENROLL>\n      <XCOURSE_COURSEPRE access=\"LOCKED\"/>\n      <XCOURSE_COURSENUM access=\"LOCKED\"/>\n      <XCOURSE_COURSENUM_SUFFIX access=\"LOCKED\"/>\n      <RESPON access=\"LOCKED\">100</RESPON>\n      <CHOURS access=\"LOCKED\">3</CHOURS>\n      <INST_MODE access=\"LOCKED\">In Person</INST_MODE>\n      <COURSE_COMP access=\"LOCKED\">Lecture</COURSE_COMP>\n    </SCHTEACH>\n  </Record>\n</Data>\n",
           headers: {
       	  'Authorization'=>'Basic VXNlcm5hbWU6UGFzc3dvcmQ=',
       	  'Content-Type'=>'text/xml'
           }).
         to_return(status: 200, body: "Success", headers: {})
      stub_request(:post, "https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University").
         with(
           body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Data>\n  <Record username=\"ghi123\">\n    <SCHTEACH>\n      <TYT_TERM access=\"LOCKED\">Spring</TYT_TERM>\n      <TYY_TERM access=\"LOCKED\">2018</TYY_TERM>\n      <TITLE access=\"LOCKED\">The Class</TITLE>\n      <DESC access=\"LOCKED\">This is the class that a teacher teaches.</DESC>\n      <COURSEPRE access=\"LOCKED\">BIO</COURSEPRE>\n      <COURSENUM access=\"LOCKED\">110</COURSENUM>\n      <COURSENUM_SUFFIX access=\"LOCKED\">B</COURSENUM_SUFFIX>\n      <SECTION access=\"LOCKED\">001</SECTION>\n      <CAMPUS access=\"LOCKED\">UP</CAMPUS>\n      <ENROLL access=\"LOCKED\">100</ENROLL>\n      <XCOURSE_COURSEPRE access=\"LOCKED\"/>\n      <XCOURSE_COURSENUM access=\"LOCKED\"/>\n      <XCOURSE_COURSENUM_SUFFIX access=\"LOCKED\"/>\n      <RESPON access=\"LOCKED\">100</RESPON>\n      <CHOURS access=\"LOCKED\">3</CHOURS>\n      <INST_MODE access=\"LOCKED\">In Person</INST_MODE>\n      <COURSE_COMP access=\"LOCKED\">Lecture</COURSE_COMP>\n    </SCHTEACH>\n  </Record>\n  <Record username=\"xxx321\">\n    <SCHTEACH>\n      <TYT_TERM access=\"LOCKED\">Spring</TYT_TERM>\n      <TYY_TERM access=\"LOCKED\">2018</TYY_TERM>\n      <TITLE access=\"LOCKED\">The Other Class</TITLE>\n      <DESC access=\"LOCKED\">This is the class that students learn in.</DESC>\n      <COURSEPRE access=\"LOCKED\">AERSP</COURSEPRE>\n      <COURSENUM access=\"LOCKED\">100</COURSENUM>\n      <COURSENUM_SUFFIX access=\"LOCKED\">A</COURSENUM_SUFFIX>\n      <SECTION access=\"LOCKED\">002</SECTION>\n      <CAMPUS access=\"LOCKED\">UP</CAMPUS>\n      <ENROLL access=\"LOCKED\">50</ENROLL>\n      <XCOURSE_COURSEPRE access=\"LOCKED\"/>\n      <XCOURSE_COURSENUM access=\"LOCKED\"/>\n      <XCOURSE_COURSENUM_SUFFIX access=\"LOCKED\"/>\n      <RESPON access=\"LOCKED\">100</RESPON>\n      <CHOURS access=\"LOCKED\">3</CHOURS>\n      <INST_MODE access=\"LOCKED\">In Person</INST_MODE>\n      <COURSE_COMP access=\"LOCKED\">Lecture</COURSE_COMP>\n    </SCHTEACH>\n  </Record>\n</Data>\n",
           headers: {
       	  'Authorization'=>'Basic VXNlcm5hbWU6UGFzc3dvcmQ=',
       	  'Content-Type'=>'text/xml'
           }).
         to_return(status: 200, body: "Success", headers: {})
      lionpath_integrate_obj.integrate
    end
  end

end

