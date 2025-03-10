require 'importers/importers_helper'

RSpec.describe PubData::PubXmlBuilder do
  let(:abc123_hash) do
    { 'data' => [{ 'pure_ids' => ['f89qu-fne8q-j98'],
                   'ai_ids' => [],
                   'attributes' => {
                     'title' => 'Title',
                     'secondary_title' => 'Second Title',
                     'publication_type' => 'Type',
                     'volume' => 34,
                     'dty' => 2017,
                     'dtm' => 'May',
                     'dtd' => 22,
                     'status' => 'Published',
                     'contributors' => [{ 'first_name' => 'Billy',
                                          'middle_name' => 'Bob',
                                          'last_name' => 'Jenkins' }],
                     'journal_title' => 'Journal Title',
                     'page_range' => '42-43',
                     'issue' => 35,
                     'edition' => 2,
                     'authors_et_al' => nil,
                     'abstract' => '<p>Some abstract</p>',
                     'citation_count' => 3
                   } }] }
  end

  let(:xyz123_hash) do
    { 'data' => [{ 'pure_ids' => ['f89qu-fne8q-j97'],
                   'ai_ids' => [],
                   'attributes' => {
                     'title' => 'Title 2',
                     'secondary_title' => 'Second Title 2',
                     'publication_type' => 'Type 2',
                     'volume' => 34,
                     'dty' => 2018,
                     'dtm' => 'June',
                     'dtd' => 20,
                     'status' => 'Published',
                     'contributors' => [{ 'first_name' => 'Franck',
                                          'middle_name' => 'Bob',
                                          'last_name' => 'Frank' }],
                     'journal_title' => 'Journal Title 2',
                     'page_range' => '43-44',
                     'issue' => 34,
                     'edition' => 3,
                     'authors_et_al' => nil,
                     'abstract' => '<p>Some abstract</p>',
                     'citation_count' => 4
                   } },

                 { 'pure_ids' => ['f89qu-fne8q-j95'],
                   'ai_ids' => [],
                   'attributes' => {
                     'title' => 'Title 3',
                     'secondary_title' => 'Second Title 3',
                     'publication_type' => 'Type 3',
                     'volume' => 33,
                     'dty' => 2012,
                     'dtm' => 'June',
                     'dtd' => 21,
                     'status' => 'Published',
                     'contributors' => [{ 'first_name' => 'Franck',
                                          'middle_name' => 'Franc',
                                          'last_name' => 'Frank' }],
                     'journal_title' => 'Journal Title 3',
                     'page_range' => '43-47',
                     'issue' => 31,
                     'edition' => 2,
                     'authors_et_al' => nil,
                     'abstract' => '<p>Some abstract</p>',
                     'citation_count' => 5
                   } }] }
  end
  let(:xml_builder_obj) { PubData::PubXmlBuilder.new }

  before do
    Faculty.create(access_id: 'abc123',
                   user_id: '123456',
                   f_name: 'Allen',
                   l_name: 'Bird',
                   m_name: 'Cat',
                   college: 'CA')
    Faculty.create(access_id: 'xyz123',
                   user_id: '54321',
                   f_name: 'Xylophone',
                   l_name: 'Zebra',
                   m_name: 'Yawn',
                   college: 'CA')
  end

  describe '#batched_pub_xml' do
    it 'returns an xml of INTELLCONT records' do
      pub_populate_db_obj = PubData::PubPopulateDb.new
      pub_populate_db_obj.populate(abc123_hash, 'abc123')
      pub_populate_db_obj.populate(xyz123_hash, 'xyz123')
      expect(xml_builder_obj.xmls_enumerator.first).to eq(
        '<?xml version="1.0" encoding="UTF-8"?>
<Data>
  <Record username="abc123">
    <INTELLCONT>
      <TITLE access="READ_ONLY">Title</TITLE>
      <TITLE_SECONDARY access="READ_ONLY">Second Title</TITLE_SECONDARY>
      <CONTYPE access="READ_ONLY">Type</CONTYPE>
      <STATUS access="READ_ONLY">Published</STATUS>
      <JOURNAL_NAME access="READ_ONLY">Journal Title</JOURNAL_NAME>
      <VOLUME access="READ_ONLY">34</VOLUME>
      <DTY_PUB access="READ_ONLY">2017</DTY_PUB>
      <DTM_PUB access="READ_ONLY">May</DTM_PUB>
      <DTD_PUB access="READ_ONLY">22</DTD_PUB>
      <EDITION access="READ_ONLY">2</EDITION>
      <PAGENUM access="READ_ONLY">42-43</PAGENUM>
      <INTELLCONT_AUTH>
        <FACULTY_NAME access="READ_ONLY">123456</FACULTY_NAME>
      </INTELLCONT_AUTH>
      <INTELLCONT_AUTH>
        <FNAME access="READ_ONLY">Billy</FNAME>
        <MNAME access="READ_ONLY">Bob</MNAME>
        <LNAME access="READ_ONLY">Jenkins</LNAME>
      </INTELLCONT_AUTH>
    </INTELLCONT>
  </Record>
  <Record username="xyz123">
    <INTELLCONT>
      <TITLE access="READ_ONLY">Title 2</TITLE>
      <TITLE_SECONDARY access="READ_ONLY">Second Title 2</TITLE_SECONDARY>
      <CONTYPE access="READ_ONLY">Type 2</CONTYPE>
      <STATUS access="READ_ONLY">Published</STATUS>
      <JOURNAL_NAME access="READ_ONLY">Journal Title 2</JOURNAL_NAME>
      <VOLUME access="READ_ONLY">34</VOLUME>
      <DTY_PUB access="READ_ONLY">2018</DTY_PUB>
      <DTM_PUB access="READ_ONLY">June</DTM_PUB>
      <DTD_PUB access="READ_ONLY">20</DTD_PUB>
      <EDITION access="READ_ONLY">3</EDITION>
      <PAGENUM access="READ_ONLY">43-44</PAGENUM>
      <INTELLCONT_AUTH>
        <FACULTY_NAME access="READ_ONLY">54321</FACULTY_NAME>
      </INTELLCONT_AUTH>
      <INTELLCONT_AUTH>
        <FNAME access="READ_ONLY">Franck</FNAME>
        <MNAME access="READ_ONLY">Bob</MNAME>
        <LNAME access="READ_ONLY">Frank</LNAME>
      </INTELLCONT_AUTH>
    </INTELLCONT>
    <INTELLCONT>
      <TITLE access="READ_ONLY">Title 3</TITLE>
      <TITLE_SECONDARY access="READ_ONLY">Second Title 3</TITLE_SECONDARY>
      <CONTYPE access="READ_ONLY">Type 3</CONTYPE>
      <STATUS access="READ_ONLY">Published</STATUS>
      <JOURNAL_NAME access="READ_ONLY">Journal Title 3</JOURNAL_NAME>
      <VOLUME access="READ_ONLY">33</VOLUME>
      <DTY_PUB access="READ_ONLY">2012</DTY_PUB>
      <DTM_PUB access="READ_ONLY">June</DTM_PUB>
      <DTD_PUB access="READ_ONLY">21</DTD_PUB>
      <EDITION access="READ_ONLY">2</EDITION>
      <PAGENUM access="READ_ONLY">43-47</PAGENUM>
      <INTELLCONT_AUTH>
        <FACULTY_NAME access="READ_ONLY">54321</FACULTY_NAME>
      </INTELLCONT_AUTH>
      <INTELLCONT_AUTH>
        <FNAME access="READ_ONLY">Franck</FNAME>
        <MNAME access="READ_ONLY">Franc</MNAME>
        <LNAME access="READ_ONLY">Frank</LNAME>
      </INTELLCONT_AUTH>
    </INTELLCONT>
  </Record>
</Data>
'
      )
    end
  end
end
