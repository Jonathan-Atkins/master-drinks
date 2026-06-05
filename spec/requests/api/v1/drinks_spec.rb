require "rails_helper"

RSpec.describe "Drinks App", type: :request do
  describe "GET /api/v1/drinks" do
    it "returns a 200 status code" do
      get "/api/v1/drinks"
      expect(response).to have_http_status(:ok)
    end

    # it "returns a JSON response with status 'ok'" do
    #   get "/api/v1/health"
    #   json_response = JSON.parse(response.body)
    #   expect(json_response["status"]).to eq("ok")
    # end
  end
end