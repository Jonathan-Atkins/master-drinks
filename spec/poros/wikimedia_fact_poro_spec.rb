require "rails_helper"

RSpec.describe WikimediaFactPoro do
  describe "#initialize" do
    it "creates a clean object from Wikimedia data" do
      data = {
        title: "Negroni",
        extract: "The Negroni is an Italian cocktail.",
        content_urls: {
          desktop: {
            page: "https://en.wikipedia.org/wiki/Negroni"
          }
        }
      }

      fact = WikimediaFactPoro.new(data)

      expect(fact.title).to eq("Negroni")
      expect(fact.summary).to eq(
        "The Negroni is an Italian cocktail."
      )
      expect(fact.source_url).to eq(
        "https://en.wikipedia.org/wiki/Negroni"
      )
    end
  end
end