require "rails_helper"

RSpec.describe WikimediaFactPoro do
  describe "#initialize" do
    describe "happy path" do
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

        fact = described_class.new(data)

        expect(fact.summary).to eq(
          "Italian cocktail"
        )
      end
    end

    describe "sad path" do
      it "returns a nil summary when Wikimedia returns no pages" do
        data = {
          pages: []
        }

        fact = described_class.new(data)

        expect(fact.summary).to be_nil
      end
    end
  end
end
