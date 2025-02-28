require 'importers/importers_helper'

RSpec.describe PubData::GetCollegePubData do
  before do
    Faculty.create(access_id: 'xyz321',
                   user_id: '54321',
                   f_name: 'Kyle',
                   l_name: 'Hamburger',
                   m_name: 'Greasy',
                   college: 'CA')
    Faculty.create(access_id: 'abc123',
                   user_id: '4321',
                   f_name: 'George',
                   l_name: 'Foreman',
                   m_name: 'Grill',
                   college: 'BK')
    allow(pub_populate_db_obj).to receive(:populate)
  end

  let(:get_pub_data_obj) { PubData::GetCollegePubData.new('All Colleges') }
  let(:abc123_response) do
    '{
    "data": [
      {
        "id": "123456",
        "type": "publication",
        "attributes": {
          "title": "Test 1",
          "secondary_title": null,
          "journal_title": "Test Journal",
          "publication_type": "Academic Journal Article",
          "publisher": null,
          "status": "Published",
          "volume": "1",
          "issue": "1",
          "edition": null,
          "page_range": "1-2",
          "authors_et_al": null,
          "abstract": null,
          "citation_count": 3,
          "published_on": "2008-01-01",
          "contributors": [
            {
              "first_name": "Alex",
              "middle_name": null,
              "last_name": "Cornmeal"
            }
          ],
          "tags": [
            {
              "name": "Tests",
              "rank": 1
            }
          ]
        }
      },
      {
        "id": "654321",
        "type": "publication",
        "attributes": {
          "title": "Test 2",
          "secondary_title": null,
          "journal_title": "Another Test Journal",
          "publication_type": "Academic Journal Article",
          "publisher": null,
          "status": "Published",
          "volume": "2",
          "issue": "2",
          "edition": null,
          "page_range": "2-3",
          "authors_et_al": null,
          "abstract": "<p>Test abstract.</p>",
          "citation_count": 0,
          "published_on": "2017-04-01",
          "contributors": [
            {
              "first_name": "Alex",
              "middle_name": null,
              "last_name": "Cornmeal"
            }
          ],
          "tags": [
            {
              "name": "Tests",
              "rank": 1
            }
          ]
        }
      }
    ]
  }'
  end

  let(:xyz321_response) do
    '{
    "data": [
      {
        "id": "678901",
        "type": "publication",
        "attributes": {
          "title": "Test 3",
          "secondary_title": null,
          "journal_title": "Yet Another Test Journal",
          "publication_type": "Academic Journal Article",
          "publisher": null,
          "status": "Published",
          "volume": "3",
          "issue": "3",
          "edition": null,
          "page_range": "3-4",
          "authors_et_al": null,
          "abstract": "<p>Test abstract 2.</p>",
          "citation_count": 6,
          "published_on": "2014-03-12",
          "contributors": [
            {
              "first_name": "Xavier",
              "middle_name": null,
              "last_name": "Zimmerman"
            }
          ],
          "tags": [
            {
              "name": "Tests",
              "rank": 1
            }
          ]
        }
      }
    ]
  }'
  end
  let(:pub_populate_db_obj) { PubData::PubPopulateDb.new }
  let(:abc123_hash) { { 'data' => [{ 'id' => '123456', 'type' => 'publication', 'attributes' => { 'title' => 'Test 1', 'secondary_title' => nil, 'journal_title' => 'Test Journal', 'publication_type' => 'Journal Article', 'publisher' => nil, 'status' => 'Published', 'volume' => '1', 'issue' => '1', 'edition' => nil, 'page_range' => '1-2', 'authors_et_al' => nil, 'abstract' => nil, 'citation_count' => 3, 'published_on' => '2008-01-01', 'contributors' => [{ 'first_name' => 'Alex', 'middle_name' => nil, 'last_name' => 'Cornmeal' }], 'tags' => [{ 'name' => 'Tests', 'rank' => 1 }], 'dtm' => 'January', 'dty' => 2008, 'dtd' => 1 } }, { 'id' => '654321', 'type' => 'publication', 'attributes' => { 'title' => 'Test 2', 'secondary_title' => nil, 'journal_title' => 'Another Test Journal', 'publication_type' => 'Journal Article', 'publisher' => nil, 'status' => 'Published', 'volume' => '2', 'issue' => '2', 'edition' => nil, 'page_range' => '2-3', 'authors_et_al' => nil, 'abstract' => '<p>Test abstract.</p>', 'citation_count' => 0, 'published_on' => '2017-04-01', 'contributors' => [{ 'first_name' => 'Alex', 'middle_name' => nil, 'last_name' => 'Cornmeal' }], 'tags' => [{ 'name' => 'Tests', 'rank' => 1 }], 'dtm' => 'April', 'dty' => 2017, 'dtd' => 1 } }] } }
  let(:xyz321_hash) { { 'data' => [{ 'id' => '678901', 'type' => 'publication', 'attributes' => { 'title' => 'Test 3', 'secondary_title' => nil, 'journal_title' => 'Yet Another Test Journal', 'publication_type' => 'Journal Article', 'publisher' => nil, 'status' => 'Published', 'volume' => '3', 'issue' => '3', 'edition' => nil, 'page_range' => '3-4', 'authors_et_al' => nil, 'abstract' => '<p>Test abstract 2.</p>', 'citation_count' => 6, 'published_on' => '2014-03-12', 'contributors' => [{ 'first_name' => 'Xavier', 'middle_name' => nil, 'last_name' => 'Zimmerman' }], 'tags' => [{ 'name' => 'Tests', 'rank' => 1 }], 'dtm' => 'March', 'dty' => 2014, 'dtd' => 12 } }] } }

  describe '#call' do
    it 'obtains publication data from Metadata Database for multiple users' do
      stub_request(:get, 'https://metadata.libraries.psu.edu/v1/users/abc123/publications')
        .with(
          body: '',
          headers: {
            'Accept' => 'application/json'
          }
        )
        .to_return(status: 200, body: abc123_response, headers: {})

      stub_request(:get, 'https://metadata.libraries.psu.edu/v1/users/xyz321/publications')
        .with(
          body: '',
          headers: {
            'Accept' => 'application/json'
          }
        )
        .to_return(status: 200, body: xyz321_response, headers: {})

      expect(pub_populate_db_obj).to receive(:populate).with(abc123_hash, 'abc123').once
      expect(pub_populate_db_obj).to receive(:populate).with(xyz321_hash, 'xyz321').once
      get_pub_data_obj.call(pub_populate_db_obj)
    end
  end
end
