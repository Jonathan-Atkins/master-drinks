require "rails_helper"

RSpec.describe WikimediaFactImporter do
  describe ".import" do
    describe "happy path" do
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

        allow(WikimediaGateway)
          .to receive(:search_page)
          .with("Negroni")
          .and_return(data)

        expect {
          WikimediaFactImporter.import("Negroni")
        }.to change(FunFact, :count).by(1)

        fact = FunFact.last

        expect(fact.body).to eq(
          "Italian cocktail"
        )

        expect(fact.drink_name).to eq(
          "Negroni"
        )
      end

      it "returns the cached FunFact without calling Wikimedia" do
        cached_fact = FunFact.create!(
          body: "Italian cocktail",
          drink_name: "Negroni"
        )

        expect(WikimediaGateway)
          .not_to receive(:search_page)

        expect {
          @result = WikimediaFactImporter.import("Negroni")
        }.not_to change(FunFact, :count)

        expect(@result).to eq(cached_fact)
      end
    end

    describe "sad path" do
      it "returns nil when Wikimedia returns no pages" do
        data = {
          pages: []
        }

        allow(WikimediaGateway)
          .to receive(:search_page)
          .with("Jonathan's Fire Water")
          .and_return(data)

        expect {
          @result = WikimediaFactImporter.import(
            "Jonathan's Fire Water"
          )
        }.not_to change(FunFact, :count)

        expect(@result).to be_nil
      end
    end
  end
end
