require 'rails_helper'
require 'activity_insight/ai_get_user_data'

RSpec.describe GetUserData do

  let(:get_user_data_obj) {GetUserData.new}

  describe '#call' do
    it 'should get user data' do
      get_user_data_obj.call

    end
  end

end
