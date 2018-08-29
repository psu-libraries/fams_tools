require 'rails_helper'

RSpec.describe PublicationListingsController, type: :request do

  describe "GET #index" do
    it "can get the publication_listings page" do
      get "/publication_listings"
      expect(response).to have_http_status(:success)
    end
  end

end
