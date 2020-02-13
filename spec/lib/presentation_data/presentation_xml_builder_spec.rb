require 'rails_helper'
require 'presentation_data/presentation_xml_builder'

RSpec.describe PresentationXMLBuilder do

  before do
    faculty = Faculty.create(access_id: 'abc123')

    presentation1 = Presentation.create(faculty: faculty,
                                        title: 'Test Presentation 1',
                                        dty_date: '2016',
                                        name: 'Name 1',
                                        org: 'Organization 1',
                                        location: 'Location 1')

    PresentationContributor.create(presentation: presentation1,
                                   f_name: 'Arnold',
                                   m_name: 'Bernie',
                                   l_name: 'Curt')
  end

  let(:xml_builder_obj) {PresentationXMLBuilder.new}

  describe '#batched_xmls' do
    it 'should return a properly formatted xml of PRESENT records' do
      expect(xml_builder_obj.xmls_enumerator.first).to eq(
'<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="abc123">
    <PRESENT>
      <TITLE access="READ_ONLY">Test Presentation 1</TITLE>
      <DTY_END access="READ_ONLY">2016</DTY_END>
      <NAME access="READ_ONLY">Name 1</NAME>
      <ORG access="READ_ONLY">Organization 1</ORG>
      <LOCATION access="READ_ONLY">Location 1</LOCATION>
      <PRESENT_AUTH>
        <FACULTY_NAME/>
      </PRESENT_AUTH>
      <PRESENT_AUTH>
        <FNAME access="READ_ONLY">Arnold</FNAME>
        <MNAME access="READ_ONLY">Bernie</MNAME>
        <LNAME access="READ_ONLY">Curt</LNAME>
      </PRESENT_AUTH>
    </PRESENT>
  </Record>
</Data>
'
      )
    end
  end
end

