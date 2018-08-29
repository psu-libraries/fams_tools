require 'rails_helper'

RSpec.describe MainController, type: :request do

  describe "GET #index" do
    it "can get the main page" do
      get "/"
      expect(response).to have_http_status(:success)

    end
  end

end
