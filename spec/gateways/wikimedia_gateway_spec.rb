require "rails_helper"
require "webmock/rspec"

RSpec.describe WikimediaGateway do
  describe ".search_page" do
    it "returns parsed Wikimedia search data" do
      stub_request(
        :get,
        "https://en.wikipedia.org/w/rest.php/v1/search/page"
      ).with(
        query: {
          q: "Negroni",
          limit: "1"
        }
      ).to_return(
        status: 200,
        body: {
          pages: [
            {
              key: "Negroni",
              title: "Negroni",
              description: "Italian cocktail",
              excerpt: "The Negroni is an Italian cocktail..."
            }
          ]
        }.to_json,
        headers: {
          "Content-Type" => "application/json"
        }
      )

      result = WikimediaGateway.search_page("Negroni")

      expect(result[:pages].first[:title]).to eq("Negroni")
    end
  end
end
