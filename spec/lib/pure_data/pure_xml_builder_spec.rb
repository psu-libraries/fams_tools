require 'rails_helper'
require 'pure_data/pure_xml_builder'

RSpec.describe PureXMLBuilder do

  let(:data_sets) do
    hash = {
      'abc123' => [{:title => 'Title',
                    :type => 'Type',
                    :volume => 34,
                    :dty => 2017,
                    :dtm => 'May',
                    :dtd => 22,
                    :status => 'Published',
                    :persons => [{:fName => 'Billy',
                                 :mName => 'Bob',
                                 :lName => 'Jenkins',
                                 :role => 'Author',
                                 :extOrg => 'Org'}],
                    :journalTitle => 'Journal Title',
                    :journalIssn => '094-024903295-32',
                    :journalNum => 4,
                    :pages => '42-43',
                    :articleNumber => 35,
                    :peerReview => 'true',
                    :url => 'www.www.www'}],
      'xyz123' => [{:title => 'Title2',
                    :type => 'Type2',
                    :volume => 12,
                    :dty => 2013,
                    :dtm => 'January',
                    :dtd => 23,
                    :status => 'Published',
                    :persons => [{:fName => 'George',
                                  :mName => 'Joe',
                                  :lName => 'Gary',
                                  :role => 'Author'},
                                  {:fName => 'Harry',
                                  :mName => 'Jorge',
                                  :lName => 'Potter',
                                  :role => 'Author'}],
                    :journalTitle => 'Journal Title2',
                    :journalIssn => '093-2351-432',
                    :journalNum => 3,
                    :pages => '42-46'},
                    {:title => 'Title3',
                    :type => 'Type3',
                    :volume => 3,
                    :dty => 2010,
                    :dtm => 'January',
                    :dtd => 03,
                    :persons => [{:fName => 'George',
                                  :mName => 'Joe',
                                  :lName => 'Gary',
                                  :role => 'Author'}],
                    :journalTitle => 'Journal Title',
                    :journalIssn => '032-42-5432-43',
                    :journalNum => 2,
                    :pages => '42-65',
                    :peerReview => 'false'}]}

    return hash
  end

  before(:each) do
    Faculty.create(access_id: 'abc123',
                   user_id:   '123456',
                   f_name:    'Allen',
                   l_name:    'Bird',
                   m_name:    'Cat')
    Faculty.create(access_id: 'xyz123',
                   user_id:   '54321',
                   f_name:    'Xylophone',
                   l_name:    'Zebra',
                   m_name:    'Yawn')
  end

  let(:pure_xml_builder_obj) {PureXMLBuilder.new}

  describe '#batched_pure_xml' do
    it 'should return an xml of INTELLCONT records' do
      data_sets.each do |k,v|
        faculty = Faculty.find_by(access_id: k)

        v.each do |pub|

          publication = Publication.create(faculty:       faculty,
                                          title:         pub[:title],
                                          status:        pub[:status],
                                          category:      pub[:type],
                                          volume:        pub[:volume],
                                          dty:           pub[:dty],
                                          dtm:           pub[:dtm],
                                          dtd:           pub[:dtd],
                                          journal_title: pub[:journalTitle],
                                          journal_issn:  pub[:journalIssn],
                                          journal_num:   pub[:journalNum],
                                          pages:         pub[:pages],
                                          articleNumber: pub[:articleNumber],
                                          peerReview:    pub[:peerReview],
                                          url:           pub[:url]
                                          )

          pub[:persons].each do |person|

            ExternalAuthor.create(publication: publication,
                                  f_name:      person[:fName],
                                  m_name:      person[:mName],
                                  l_name:      person[:lName],
                                  role:        person[:role],
                                  extOrg:      person[:extOrg]
                                  )
          end
        end
      end
      expect(pure_xml_builder_obj.batched_xmls).to eq([
'<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="abc123">
    <INTELLCONT>
      <TITLE access="READ_ONLY">Title</TITLE>
      <CONTYPE access="READ_ONLY">Type</CONTYPE>
      <STATUS access="READ_ONLY">Published</STATUS>
      <JOURNAL_NAME access="READ_ONLY">Journal Title</JOURNAL_NAME>
      <ISBNISSN access="READ_ONLY">094-024903295-32</ISBNISSN>
      <VOLUME access="READ_ONLY">34</VOLUME>
      <DTY_PUB access="READ_ONLY">2017</DTY_PUB>
      <DTM_PUB access="READ_ONLY">May</DTM_PUB>
      <DTD_PUB access="READ_ONLY">22</DTD_PUB>
      <ISSUE access="READ_ONLY">4</ISSUE>
      <PAGENUM access="READ_ONLY">42-43</PAGENUM>
      <INTELLCONT_AUTH>
        <FNAME access="READ_ONLY">Billy</FNAME>
        <MNAME access="READ_ONLY">Bob</MNAME>
        <LNAME access="READ_ONLY">Jenkins</LNAME>
        <ROLE access="READ_ONLY">Author</ROLE>
        <INSTITUTION access="READ_ONLY">Org</INSTITUTION>
      </INTELLCONT_AUTH>
      <WEB_ADDRESS access="READ_ONLY">www.www.www</WEB_ADDRESS>
      <REFEREED access="READ_ONLY">true</REFEREED>
    </INTELLCONT>
  </Record>
  <Record username="xyz123">
    <INTELLCONT>
      <TITLE access="READ_ONLY">Title2</TITLE>
      <CONTYPE access="READ_ONLY">Type2</CONTYPE>
      <STATUS access="READ_ONLY">Published</STATUS>
      <JOURNAL_NAME access="READ_ONLY">Journal Title2</JOURNAL_NAME>
      <ISBNISSN access="READ_ONLY">093-2351-432</ISBNISSN>
      <VOLUME access="READ_ONLY">12</VOLUME>
      <DTY_PUB access="READ_ONLY">2013</DTY_PUB>
      <DTM_PUB access="READ_ONLY">January</DTM_PUB>
      <DTD_PUB access="READ_ONLY">23</DTD_PUB>
      <ISSUE access="READ_ONLY">3</ISSUE>
      <PAGENUM access="READ_ONLY">42-46</PAGENUM>
      <INTELLCONT_AUTH>
        <FNAME access="READ_ONLY">George</FNAME>
        <MNAME access="READ_ONLY">Joe</MNAME>
        <LNAME access="READ_ONLY">Gary</LNAME>
        <ROLE access="READ_ONLY">Author</ROLE>
        <INSTITUTION access="READ_ONLY"/>
      </INTELLCONT_AUTH>
      <INTELLCONT_AUTH>
        <FNAME access="READ_ONLY">Harry</FNAME>
        <MNAME access="READ_ONLY">Jorge</MNAME>
        <LNAME access="READ_ONLY">Potter</LNAME>
        <ROLE access="READ_ONLY">Author</ROLE>
        <INSTITUTION access="READ_ONLY"/>
      </INTELLCONT_AUTH>
      <WEB_ADDRESS access="READ_ONLY"/>
      <REFEREED access="READ_ONLY"/>
    </INTELLCONT>
    <INTELLCONT>
      <TITLE access="READ_ONLY">Title3</TITLE>
      <CONTYPE access="READ_ONLY">Type3</CONTYPE>
      <STATUS access="READ_ONLY"/>
      <JOURNAL_NAME access="READ_ONLY">Journal Title</JOURNAL_NAME>
      <ISBNISSN access="READ_ONLY">032-42-5432-43</ISBNISSN>
      <VOLUME access="READ_ONLY">3</VOLUME>
      <DTY_PUB access="READ_ONLY">2010</DTY_PUB>
      <DTM_PUB access="READ_ONLY">January</DTM_PUB>
      <DTD_PUB access="READ_ONLY">3</DTD_PUB>
      <ISSUE access="READ_ONLY">2</ISSUE>
      <PAGENUM access="READ_ONLY">42-65</PAGENUM>
      <INTELLCONT_AUTH>
        <FNAME access="READ_ONLY">George</FNAME>
        <MNAME access="READ_ONLY">Joe</MNAME>
        <LNAME access="READ_ONLY">Gary</LNAME>
        <ROLE access="READ_ONLY">Author</ROLE>
        <INSTITUTION access="READ_ONLY"/>
      </INTELLCONT_AUTH>
      <WEB_ADDRESS access="READ_ONLY"/>
      <REFEREED access="READ_ONLY">false</REFEREED>
    </INTELLCONT>
  </Record>
</Data>
'])
    end
  end
end