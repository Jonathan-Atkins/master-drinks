require "rails_helper"
require "webmock/rspec"

RSpec.describe WikimediaGateway do
  describe ".search_page" do
    describe "happy path" do
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

        expect(
          result[:pages].first[:title]
        ).to eq("Negroni")
      end

      it "sends a User-Agent header" do
        request = stub_request(
          :get,
          "https://en.wikipedia.org/w/rest.php/v1/search/page"
        ).with(
          query: {
            q: "Negroni",
            limit: "1"
          },
          headers: {
            "User-Agent" => "BarBuddy/1.0"
          }
        ).to_return(
          status: 200,
          body: {
            pages: []
          }.to_json
        )

        WikimediaGateway.search_page("Negroni")

        expect(request).to have_been_requested.once
      end
    end

    describe "sad path" do
      it "returns an empty pages array when Wikimedia returns an error" do
        stub_request(
          :get,
          "https://en.wikipedia.org/w/rest.php/v1/search/page"
        ).with(
          query: {
            q: "Negroni",
            limit: "1"
          }
        ).to_return(
          status: 500,
          body: "Internal Server Error"
        )

        result = WikimediaGateway.search_page("Negroni")

        expect(result).to eq(
          pages: []
        )
      end

      it "returns an empty pages array when Wikimedia times out" do
        stub_request(
          :get,
          "https://en.wikipedia.org/w/rest.php/v1/search/page"
        ).with(
          query: {
            q: "Negroni",
            limit: "1"
          }
        ).to_timeout

        result = WikimediaGateway.search_page("Negroni")

        expect(result).to eq(
          pages: []
        )
      end

      it "returns an empty pages array when Wikimedia returns invalid JSON" do
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
          body: "not valid json"
        )

        result = WikimediaGateway.search_page("Negroni")

        expect(result).to eq(
          pages: []
        )
      end
    end
  end
end
