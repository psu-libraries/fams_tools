require 'rails_helper'

RSpec.describe AiIntegrationController, type: :request do

  describe "GET #index" do
    it "can get the ai_integration page" do
      get "/ai_integration"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #osp_integrate" do 
    it "can invoke osp integration" do
      post "osp_integrate", :params => {:congrant_file => fixture_file_upload('files/fake_osp_data.txt'), :ai_backup_file => fixture_file_upload('files/fake_ai_backup_file.txt')}
      expect(response).to have_http_status(:success)
    end
  end

end
