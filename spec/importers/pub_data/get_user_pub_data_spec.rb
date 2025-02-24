require 'importers/importers_helper'

RSpec.describe PubData::GetUserPubData do
  before do
    Faculty.create(access_id: 'abc123',
                   user_id: '4321',
                   f_name: 'George',
                   l_name: 'Foreman',
                   m_name: 'Grill',
                   college: 'BK')
    allow(pub_populate_db_obj).to receive(:populate)
  end

  let(:get_pub_data_obj) { PubData::GetUserPubData.new('abc123') }
  let(:response1) do
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

  let(:pub_populate_db_obj) { PubData::PubPopulateDb.new }
  let(:abc123_hash) { { 'data' => [{ 'id' => '123456', 'type' => 'publication', 'attributes' => { 'title' => 'Test 1', 'secondary_title' => nil, 'journal_title' => 'Test Journal', 'publication_type' => 'Journal Article', 'publisher' => nil, 'status' => 'Published', 'volume' => '1', 'issue' => '1', 'edition' => nil, 'page_range' => '1-2', 'authors_et_al' => nil, 'abstract' => nil, 'citation_count' => 3, 'published_on' => '2008-01-01', 'contributors' => [{ 'first_name' => 'Alex', 'middle_name' => nil, 'last_name' => 'Cornmeal' }], 'tags' => [{ 'name' => 'Tests', 'rank' => 1 }], 'dtm' => 'January', 'dty' => 2008, 'dtd' => 1 } }, { 'id' => '654321', 'type' => 'publication', 'attributes' => { 'title' => 'Test 2', 'secondary_title' => nil, 'journal_title' => 'Another Test Journal', 'publication_type' => 'Journal Article', 'publisher' => nil, 'status' => 'Published', 'volume' => '2', 'issue' => '2', 'edition' => nil, 'page_range' => '2-3', 'authors_et_al' => nil, 'abstract' => '<p>Test abstract.</p>', 'citation_count' => 0, 'published_on' => '2017-04-01', 'contributors' => [{ 'first_name' => 'Alex', 'middle_name' => nil, 'last_name' => 'Cornmeal' }], 'tags' => [{ 'name' => 'Tests', 'rank' => 1 }], 'dtm' => 'April', 'dty' => 2017, 'dtd' => 1 } }] } }

  describe '#call' do
    it 'obtains publication data from Metadata Database for one user' do
      stub_request(:get, 'https://metadata.libraries.psu.edu/v1/users/abc123/publications')
        .with(
          body: '',
          headers: {
            'Accept' => 'application/json'
          }
        )
        .to_return(status: 200, body: response1, headers: {})
      expect(pub_populate_db_obj).to receive(:populate).with(abc123_hash, 'abc123').once
      get_pub_data_obj.call(pub_populate_db_obj)
    end
  end
end
