require 'rails_helper'

RSpec.describe AiIntegrationController, type: :controller do

  describe "GET #index" do
    it "can get the ai_integration page" do
      get "index"
      expect(response).to render_template(:index)
    end
  end

  describe "POST #osp_integrate" do 
    it "can invoke osp integration" do
      post "osp_integrate", :params => {:congrant_file => fixture_file_upload('files/fake_osp_data.txt'), :ai_backup_file => fixture_file_upload('files/fake_ai_backup_file.txt')}
      puts response
    end
  end

end
