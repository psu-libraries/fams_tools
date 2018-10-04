require 'rails_helper'
require 'pub_data/get_pub_data'

RSpec.describe GetPubData do

  before(:each) do
    faculty1 = Faculty.create(access_id: 'xyz321',
                             user_id:   '54321',
                             f_name:    'Kyle',
                             l_name:    'Hamburger',
                             m_name:    'Greasy',
                             college:   'CA')
    faculty2 = Faculty.create(access_id: 'abc123',
                             user_id:   '4321',
                             f_name:    'George',
                             l_name:    'Foreman',
                             m_name:    'Grill',
                             college:   'BK')
  end

  let(:get_pub_data_obj) {GetPubData.new}

  describe '#call' do
    it 'should obtain publication data from Pure' do

      stub_request(:post, "https://stage.metadata.libraries.psu.edu/v1/users/publications").
         with(
           body: ["abc123", "xyz321"],
           headers: {
       	  'Accept'=>'application/xml',
       	  'Api-Key'=>'bf5beedf-55a2-4260-9708-b3b7466defef'
           }).
         to_return(status: 200, body: response, headers: {})

      get_pub_data_obj.call
      expect(get_pub_data_obj.pub_hash['abc123']['data'][0]["attributes"]["status"]).to eq('Published')
      expect(get_pub_data_obj.pub_hash['xyz321']['data'][0]["attributes"]["status"]).to eq('Published')
      expect(get_pub_data_obj.pub_hash['abc123']['data'][0]["attributes"]["dtm"]).to eq('January (1st Quarter/Winter)')
      expect(get_pub_data_obj.pub_hash['xyz321']['data'][0]["attributes"]["dtm"]).to eq('March')
      expect(get_pub_data_obj.pub_hash['abc123']['data'][0]["attributes"]["dty"]).to eq('2008')
      expect(get_pub_data_obj.pub_hash['abc123']['data'][0]["attributes"]["dtd"]).to eq("1")
      expect(get_pub_data_obj.pub_hash['xyz321']['data'][0]["attributes"]["publication_type"]).to eq('Academic Journal Article')
      expect(get_pub_data_obj.pub_hash['abc123']['data'][1]["attributes"]["publication_type"]).to eq('Academic Journal Article')
      expect(get_pub_data_obj.pub_hash['abc123']['data'][0]["attributes"]["page_range"]).to eq('1-2')
    end
  end

  private

  def response
'{
  "abc123": {
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
  },

  "xyz321": {
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
  }
}'
  end

end
