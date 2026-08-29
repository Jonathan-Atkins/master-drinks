require "rails_helper"
require "webmock/rspec"

RSpec.describe WikimediaGateway do
  describe ".get_summary" do
    context "happy path" do
      it "returns parsed Wikimedia data" do
        stub_request(
          :get,
          "https://en.wikipedia.org/api/rest_v1/page/summary/Negroni"
        ).to_return(
          status: 200,
          body: {
            title: "Negroni",
            extract: "The Negroni is an Italian cocktail."
          }.to_json,
          headers: {
            "Content-Type" => "application/json"
          }
        )

        result = WikimediaGateway.get_summary("Negroni")

        expect(result[:title]).to eq("Negroni")
        expect(result[:extract]).to eq(
          "The Negroni is an Italian cocktail."
        )
      end
    end
  end
end