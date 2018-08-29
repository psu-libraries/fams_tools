require 'rails_helper'

RSpec.describe MainController, type: :request do

  describe "GET #index" do
    it "can get the main page" do
      get "index"
      expect(response).to render_template(:index)

    end
  end

end
