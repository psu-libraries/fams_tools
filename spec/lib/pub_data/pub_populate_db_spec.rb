require 'rails_helper'
require 'pub_data/pub_populate_db'

RSpec.describe PubPopulateDB do

  let(:fake_data) do
    {"abc123"=>{"data"=>[{"id"=>"123456", "type"=>"publication", "attributes"=>{"title"=>"Test 1", "secondary_title"=>nil, "journal_title"=>"Test Journal", "publication_type"=>"Academic Journal Article", "publisher"=>nil, "status"=>"Published", "volume"=>"1", "issue"=>"1", "edition"=>nil, "page_range"=>"1-2", "authors_et_al"=>nil, "abstract"=>nil, "citation_count"=>3, "published_on"=>"2008-01-01", "contributors"=>[{"first_name"=>"Alex", "middle_name"=>nil, "last_name"=>"Cornmeal"}], "tags"=>[{"name"=>"Tests", "rank"=>1}], "dtm"=>"January (1st Quarter/Winter)", "dty"=>"2008", "dtd"=>"1"}}, {"id"=>"654321", "type"=>"publication", "attributes"=>{"title"=>"Test 2", "secondary_title"=>nil, "journal_title"=>"Another Test Journal", "publication_type"=>"Academic Journal Article", "publisher"=>nil, "status"=>"Published", "volume"=>"2", "issue"=>"2", "edition"=>nil, "page_range"=>"2-3", "authors_et_al"=>nil, "abstract"=>"<p>Test abstract.</p>", "citation_count"=>0, "published_on"=>"2017-04-01", "contributors"=>[{"first_name"=>"Alex", "middle_name"=>nil, "last_name"=>"Cornmeal"}], "tags"=>[{"name"=>"Tests", "rank"=>1}], "dtm"=>"April (2nd Quarter/Spring)", "dty"=>"2017", "dtd"=>"1"}}]}, "xyz321"=>{"data"=>[{"id"=>"678901", "type"=>"publication", "attributes"=>{"title"=>"Test 3", "secondary_title"=>nil, "journal_title"=>"Yet Another Test Journal", "publication_type"=>"Academic Journal Article", "publisher"=>nil, "status"=>"Published", "volume"=>"3", "issue"=>"3", "edition"=>nil, "page_range"=>"3-4", "authors_et_al"=>nil, "abstract"=>"<p>Test abstract 2.</p>", "citation_count"=>6, "published_on"=>"2014-03-12", "contributors"=>[{"first_name"=>"Xavier", "middle_name"=>nil, "last_name"=>"Zimmerman"}], "tags"=>[{"name"=>"Tests", "rank"=>1}], "dtm"=>"March", "dty"=>"2014", "dtd"=>"12"}}]}}
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

  describe '#populate' do
    it 'should populate the database with pub data' do
      pub_data_obj = double()
      allow(pub_data_obj).to receive(:call)
      allow(pub_data_obj).to receive(:pub_hash).and_return(fake_data)
      pub_populate_db_obj = PubPopulateDB.new(pub_data_obj)

      pub_populate_db_obj.populate
      expect(Publication.all.count).to eq(3)
      expect(Publication.first.title).to eq('Title')
      expect(Faculty.find_by(access_id: 'abc123').publication_faculty_links.first.publication.external_authors.first.f_name).to eq('Billy')
      expect(Faculty.find_by(access_id: 'xyz123').publication_faculty_links.first.publication.external_authors.all.count).to eq(2)
      expect(Faculty.find_by(access_id: 'xyz123').publication_faculty_links.last.publication.peerReview).to eq("false")
      expect(Publication.first.publication_faculty_links.first.category).to eq('Research Article')
    end
  end

end
