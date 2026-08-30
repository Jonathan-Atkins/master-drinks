require "rails_helper"

RSpec.describe WikimediaFactImporter do
  describe ".import" do
    context "happy path" do
      it "creates a FunFact from Wikimedia data" do
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

        allow(WikimediaGateway).to receive(:search_page)
            .with("Negroni")
            .and_return(data)

        expect {
          WikimediaFactImporter.import("Negroni")
        }.to change(FunFact, :count).by(1)

        fact = FunFact.last

        expect(fact.body).to eq(
          "Italian cocktail"
        )
        expect(fact.source_name).to eq("Wikipedia")
        expect(fact.source_url).to eq(
          "https://en.wikipedia.org/wiki/Negroni"
        )
        expect(fact.category).to eq("cocktail-history")
      end
    end
  end
end
