require 'importers/importers_helper'

RSpec.describe PubData::PubPopulateDb do
  let(:abc123_hash) { { 'data' => [{ 'id' => '123456', 'type' => 'publication', 'attributes' => { 'title' => 'Test 1', 'secondary_title' => 'Second title', 'journal_title' => 'Test Journal', 'publication_type' => 'Journal Article', 'publisher' => nil, 'status' => 'Published', 'volume' => '1', 'issue' => '1', 'edition' => nil, 'page_range' => '1-2', 'authors_et_al' => nil, 'abstract' => nil, 'citation_count' => 3, 'published_on' => '2008-01-01', 'contributors' => [{ 'first_name' => 'Alex', 'middle_name' => nil, 'last_name' => 'Cornmeal' }], 'tags' => [{ 'name' => 'Tests', 'rank' => 1 }], 'dtm' => 'January', 'dty' => 2008, 'dtd' => 1 } }, { 'id' => '654321', 'type' => 'publication', 'attributes' => { 'title' => 'Test 2', 'secondary_title' => nil, 'journal_title' => 'Another Test Journal', 'publication_type' => 'Journal Article', 'publisher' => nil, 'status' => 'Published', 'volume' => '2', 'issue' => '2', 'edition' => nil, 'page_range' => '2-3', 'authors_et_al' => nil, 'abstract' => '<p>Test abstract.</p>', 'citation_count' => 0, 'published_on' => '2017-04-01', 'contributors' => [{ 'first_name' => 'Alex', 'middle_name' => nil, 'last_name' => 'Cornmeal' }], 'tags' => [{ 'name' => 'Tests', 'rank' => 1 }], 'dtm' => 'April', 'dty' => 2017, 'dtd' => 1 } }] } }
  let(:xyz321_hash) { { 'data' => [{ 'id' => '678901', 'type' => 'publication', 'attributes' => { 'title' => 'Test 3', 'secondary_title' => nil, 'journal_title' => 'Yet Another Test Journal', 'publication_type' => 'Journal Article', 'publisher' => nil, 'status' => 'Published', 'volume' => '3', 'issue' => '3', 'edition' => nil, 'page_range' => '3-4', 'authors_et_al' => nil, 'abstract' => '<p>Test abstract 2.</p>', 'citation_count' => 6, 'published_on' => '2014-03-12', 'contributors' => [{ 'first_name' => 'Xavier', 'middle_name' => nil, 'last_name' => 'Zimmerman' }], 'tags' => [{ 'name' => 'Tests', 'rank' => 1 }], 'dtm' => 'March', 'dty' => 2014, 'dtd' => 12 } }] } }
  let(:pub_populate) { PubData::PubPopulateDb.new }

  before do
    Faculty.create(access_id: 'abc123',
                   user_id: '123456',
                   f_name: 'Allen',
                   l_name: 'Bird',
                   m_name: 'Cat')
    Faculty.create(access_id: 'xyz321',
                   user_id: '54321',
                   f_name: 'Xylophone',
                   l_name: 'Zebra',
                   m_name: 'Yawn')
  end

  describe '#populate' do
    it 'populates the database with pub data' do
      pub_populate.populate(abc123_hash, 'abc123')
      pub_populate.populate(xyz321_hash, 'xyz321')

      expect(Publication.count).to eq(3)
      expect(Publication.first.title).to eq('Test 1')
      expect(Publication.first.volume).to eq(1)
      expect(Publication.first.dty).to eq(2008)
      expect(Publication.first.dtd).to eq(1)
      expect(Publication.first.journal_title).to eq('Test Journal')
      expect(Publication.first.page_range).to eq('1-2')
      expect(Publication.first.edition).to eq(nil)
      expect(Publication.first.abstract).to eq(nil)
      expect(Publication.first.secondary_title).to eq('Second title')
      expect(Publication.first.citation_count).to eq(nil)
      expect(Publication.first.authors_et_al).to eq(nil)
      expect(Faculty.find_by(access_id: 'abc123').publication_faculty_links.first.publication.external_authors.first.f_name).to eq('Alex')
      expect(Faculty.find_by(access_id: 'abc123').publication_faculty_links.first.publication.external_authors.count).to eq(1)
      expect(Publication.first.publication_faculty_links.first.category).to eq('Journal Article')
      expect(Publication.first.publication_faculty_links.first.dtm).to eq('January')
      expect(Publication.first.publication_faculty_links.first.status).to eq('Published')
    end
  end
end
