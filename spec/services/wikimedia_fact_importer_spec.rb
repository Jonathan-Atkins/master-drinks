require "rails_helper"

RSpec.describe WikimediaFactImporter do
  describe ".import" do
    context "happy path" do
      it "creates a FunFact from Wikimedia data" do
        data = {
          title: "Negroni",
          extract: "The Negroni is an Italian cocktail.",
          content_urls: {
            desktop: {
              page: "https://en.wikipedia.org/wiki/Negroni"
            }
          }
        }

        allow(WikimediaGateway)
          .to receive(:get_summary)
          .with("Negroni")
          .and_return(data)

        expect {
          WikimediaFactImporter.import("Negroni")
        }.to change(FunFact, :count).by(1)

        fact = FunFact.last

        expect(fact.body).to eq(
          "The Negroni is an Italian cocktail."
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