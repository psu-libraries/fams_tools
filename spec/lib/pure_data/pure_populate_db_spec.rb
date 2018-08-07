require 'rails_helper'
require 'pure_data/pure_populate_db'

RSpec.describe PurePopulateDB do

  let(:fake_data) do
    hash = {
      'abc123' => [{:title => 'Title',
                    :category => 'Research Article',
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
                    :journaluuid => 'abc123-098xyz',
                    :journalNum => 4,
                    :pages => '42-43',
                    :articleNumber => 35,
                    :peerReview => 'true',
                    :url => 'www.www.www'}],
      'xyz123' => [{:title => 'Title2',
                    :category => 'Research Article',
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
                    :journaluuid => 'abc123-098xyz',
                    :journalNum => 3,
                    :pages => '42-46'},
                    {:title => 'Title3',
                    :category => 'Type3',
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
                    :journaluuid => 'abc123-098xyz',
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

  describe '#populate' do
    it 'should populate the database with pure data' do
      pure_data_obj = double()
      allow(pure_data_obj).to receive(:call)
      allow(pure_data_obj).to receive(:pure_hash).and_return(fake_data)
      pure_populate_db_obj = PurePopulateDB.new(pure_data_obj)

      pure_populate_db_obj.populate
      expect(Publication.all.count).to eq(3)
      expect(Publication.first.title).to eq('Title')
      expect(Faculty.find_by(access_id: 'abc123').publications.first.external_authors.first.f_name).to eq('Billy')
      expect(Faculty.find_by(access_id: 'xyz123').publications.first.external_authors.all.count).to eq(2)
      expect(Faculty.find_by(access_id: 'xyz123').publications.last.peerReview).to eq("false")
      expect(Publication.first.status).to eq('Published')
      expect(Publication.first.category).to eq('Research Article')
    end
  end

end
