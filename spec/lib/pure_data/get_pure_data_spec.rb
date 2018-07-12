require 'rails_helper'
require 'pure_data/get_pure_data'

RSpec.describe GetPureData do

  before(:each) do
    faculty1 = Faculty.create(access_id: 'xyz321',
                             user_id:   '54321',
                             f_name:    'Kyle',
                             l_name:    'Hamburger',
                             m_name:    'Greasy')
    faculty2 = Faculty.create(access_id: 'abc123',
                             user_id:   '4321',
                             f_name:    'George',
                             l_name:    'Foreman',
                             m_name:    'Grill')

    PureId.create(faculty: faculty1,
                  pure_id: 123)

    PureId.create(faculty: faculty2,
                  pure_id: 321)
  end

  let(:get_pure_data_obj) {GetPureData.new}

  describe '#call' do
    it 'should obtain publication data from Pure' do
      stub_request(:get, Regexp.new("https://pennstate.pure.elsevier.com/ws/api/511/persons/123")).
         to_return(status: 200, body: '
<result xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://pennstate.pure.elsevier.com/ws/api/511/xsd/schema1.xsd">
  <contributionToJournal uuid="" pureId="453" externalId="" externalIdSource="Scopus">
    <title>Cool Title</title>
    <type>Article</type>
    <peerReview>true</peerReview>
    <publicationStatuses>
      <publicationStatus current="true">
        <publicationStatus pureId="" uri="/dk/atira/pure/researchoutput/status/published">Published</publicationStatus>
        <publicationDate>
          <year>2011</year>
          <month>11</month>
          <day>11</day>
        </publicationDate>
      </publicationStatus>
    </publicationStatuses>
    <personAssociations>
      <personAssociation pureId="">
        <name>
          <firstName>Bill</firstName>
          <lastName>Frank</lastName>
        </name>
        <personRole pureId="" uri="/dk/atira/pure/researchoutput/roles/contributiontojournal/author">Author</personRole>
      </personAssociation>
    </personAssociations>
    <journalAssociation pureId="">
      <title>Journal of Stuff</title>
      <issn>5432-5432</issn>
    </journalAssociation>
    <pages>45-60</pages>
    <volume>56</volume>
    <journalNumber>5</journalNumber>
  </contributionToJournal>
  <contributionToJournal uuid="" pureId="321" externalId="" externalIdSource="Scopus">
    <title>Cooler Title</title>
    <type>Article</type>
    <peerReview>true</peerReview>
    <publicationStatuses>
      <publicationStatus current="true">
        <publicationStatus pureId="" uri="/dk/atira/pure/researchoutput/status/published">Published</publicationStatus>
        <publicationDate>
          <year>2010</year>
          <month>10</month>
          <day>10</day>
        </publicationDate>
      </publicationStatus>
    </publicationStatuses>
    <personAssociations>
      <personAssociation pureId="">
        <name>
          <firstName>Will</firstName>
          <lastName>Craig</lastName>
        </name>
        <personRole pureId="" uri="/dk/atira/pure/researchoutput/roles/contributiontojournal/author">Author</personRole>
      </personAssociation>
      <personAssociation pureId="">
        <name>
          <firstName>Terry</firstName>
          <middleName>Jerry</middleName>
          <lastName>Smith</lastName>
        </name>
        <personRole pureId="" uri="/dk/atira/pure/researchoutput/roles/contributiontojournal/author">Author</personRole>
      </personAssociation>
    </personAssociations>
    <journalAssociation pureId="">
      <title>Journal of Stuff</title>
      <issn>431-4321</issn>
    </journalAssociation>
    <pages>100-150</pages>
    <volume>3</volume>
    <journalNumber>7</journalNumber>
  </contributionToJournal>
</result>', headers: {})
      stub_request(:get, Regexp.new("https://pennstate.pure.elsevier.com/ws/api/511/persons/321")).
         to_return(status: 200, body: '
<result xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://pennstate.pure.elsevier.com/ws/api/511/xsd/schema1.xsd">
  <contributionToJournal uuid="" pureId="453" externalId="" externalIdSource="Scopus">
    <title>Cool Title</title>
    <type>Article</type>
    <peerReview>true</peerReview>
    <publicationStatuses>
      <publicationStatus current="true">
        <publicationStatus pureId="" uri="/dk/atira/pure/researchoutput/status/published">Published</publicationStatus>
        <publicationDate>
          <year>2011</year>
          <month>11</month>
          <day>11</day>
        </publicationDate>
      </publicationStatus>
    </publicationStatuses>
    <personAssociations>
      <personAssociation pureId="">
        <name>
          <firstName>Bill</firstName>
          <lastName>Frank</lastName>
        </name>
        <personRole pureId="" uri="/dk/atira/pure/researchoutput/roles/contributiontojournal/author">Author</personRole>
        <externalOrganisations>
          <externalOrganisation uuid="">
            <name>University</name>
          </externalOrganisation>
        </externalOrganisations>
      </personAssociation>
    </personAssociations>
    <electronicVersions>
      <electronicVersion xsi:type="" pureId="">
        <doi>www.website.org</doi>
      </electronicVersion>
    </electronicVersion>
    <journalAssociation pureId="">
      <title>Journal of Stuff</title>
      <issn>5432-5432</issn>
    </journalAssociation>
    <articleNumber>20</articleNumber>
    <pages>45-60</pages>
    <volume>56</volume>
    <journalNumber>5</journalNumber>
  </contributionToJournal>
</result>', headers: {})
      get_pure_data_obj.call
      expect(get_pure_data_obj.pure_hash['abc123'][0][:persons][0][:extOrg]).to eq('University')
      expect(get_pure_data_obj.pure_hash['abc123'][0][:status]).to eq('Published')
      expect(get_pure_data_obj.pure_hash['abc123'][0][:articleNumber]).to eq('20')
      expect(get_pure_data_obj.pure_hash['abc123'][0][:peerReview]).to eq('true')
      expect(get_pure_data_obj.pure_hash['abc123'][0][:url]).to eq('www.website.org')
    end
  end

end