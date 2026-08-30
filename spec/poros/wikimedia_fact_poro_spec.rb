require "rails_helper"

RSpec.describe WikimediaFactPoro do
  describe "#initialize" do
    it "creates a clean object from Wikimedia search data" do
      data = {
        pages: [
          {
            key: "Negroni",
            title: "Negroni",
            description: "Italian cocktail",
            excerpt: "The Negroni is an Italian cocktail."
          }
        ]
      }

      fact = WikimediaFactPoro.new(data)

      expect(fact.title).to eq("Negroni")

      expect(fact.summary).to eq(
        "Italian cocktail"
      )

      expect(fact.source_url).to eq(
        "#{WikimediaGateway::BASE_URL}/wiki/Negroni"
      )
    end
  end
end
