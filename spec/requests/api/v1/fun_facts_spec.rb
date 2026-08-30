require "rails_helper"

RSpec.describe "FunFacts API", type: :request do
  describe "GET /api/v1/fun_facts" do
    context "happy path" do
      it "returns all fun facts" do
        FunFact.create!(
          body: "The Negroni is an Italian cocktail.",
          source_name: "Wikipedia",
          source_url: "https://en.wikipedia.org/wiki/Negroni",
          category: "cocktail-history"
        )

        get "/api/v1/fun_facts"

        expect(response).to have_http_status(:ok)

        data = JSON.parse(response.body, symbolize_names: true)

        expect(data.count).to eq(1)
        expect(data.first[:body]).to eq(
          "The Negroni is an Italian cocktail."
        )
      end
    end

    context "sad path" do
      it "returns an empty array when there are no fun facts" do
        get "/api/v1/fun_facts"

        expect(response).to have_http_status(:ok)

        data = JSON.parse(response.body)

        expect(data).to eq([])
      end
    end
  end
end
