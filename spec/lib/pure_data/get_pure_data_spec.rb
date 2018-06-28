require 'rails_helper'
require 'pure_data/get_pure_ids'

RSpec.describe GetPureIDs do

  before(:each) do
    Faculty.create(access_id: 'xyz321',
                   user_id:   '54321',
                   f_name:    'Kyle',
                   l_name:    'Hamburger',
                   m_name:    'Greasy')
    Faculty.create(access_id: 'abc123',
                   user_id:   '98765',
                   f_name:    'Dorothy',
                   l_name:    'Glycerine',
                   m_name:    'Orange')
    Faculty.create(access_id: 'zzz999',
                   user_id:   '76584',
                   f_name:    'Yolanda',
                   l_name:    'Nigel',
                   m_name:    'Table')
  end

  let(:get_pure_ids_obj) {GetPureIDs.new}

  describe '#call' do
    it 'should obtain publication data from Pure' do
    end
  end

end
