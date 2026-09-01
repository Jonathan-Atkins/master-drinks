require "rails_helper"

RSpec.describe WikimediaFactImporter do
  describe ".import" do
    context "happy path" do
      it "searches for the drink as a cocktail and caches the full Wikipedia extract" do
        search_response = {
          pages: [
            {
              title: "Margarita",
              description: "Mexican cocktail"
            }
          ]
        }

        extract = <<~TEXT.squish
          A margarita is a cocktail of tequila,
          triple sec, lime juice, and sometimes
          simple syrup. It is served shaken with
          ice, straight up, or blended with ice.
        TEXT

        extract_response = {
          query: {
            pages: [
              {
                title: "Margarita",
                extract: extract
              }
            ]
          }
        }

        expect(
          WikimediaGateway
        ).to receive(
          :search_page
        ).with(
          "Margarita cocktail"
        ).and_return(
          search_response
        )

        expect(
          WikimediaGateway
        ).to receive(
          :fetch_extract
        ).with(
          "Margarita"
        ).and_return(
          extract_response
        )

        result = nil

        expect {
          result =
            described_class.import(
              "Margarita"
            )
        }.to change(
          FunFact,
          :count
        ).by(1)

        expect(
          result.drink_name
        ).to eq("Margarita")

        expect(
          result.body
        ).to eq(extract)
      end

      it "uses the resolved Wikipedia title when fetching the extract" do
        search_response = {
          pages: [
            {
              title: "Old fashioned (cocktail)",
              description: "Whiskey cocktail"
            }
          ]
        }

        extract_response = {
          query: {
            pages: [
              {
                title: "Old fashioned (cocktail)",
                extract:
                  "The old fashioned is a cocktail made with whiskey, sugar, and bitters."
              }
            ]
          }
        }

        expect(
          WikimediaGateway
        ).to receive(
          :search_page
        ).with(
          "Old Fashioned cocktail"
        ).and_return(
          search_response
        )

        expect(
          WikimediaGateway
        ).to receive(
          :fetch_extract
        ).with(
          "Old fashioned (cocktail)"
        ).and_return(
          extract_response
        )

        result =
          described_class.import(
            "Old Fashioned"
          )

        expect(
          result.body
        ).to eq(
          "The old fashioned is a cocktail made with whiskey, sugar, and bitters."
        )

        expect(
          result.drink_name
        ).to eq(
          "Old Fashioned"
        )
      end

      it "returns the cached fact without calling Wikimedia again" do
        cached_fact =
          FunFact.create!(
            body:
              "Previously cached full extract.",
            drink_name:
              "Negroni"
          )

        expect(
          WikimediaGateway
        ).not_to receive(
          :search_page
        )

        expect(
          WikimediaGateway
        ).not_to receive(
          :fetch_extract
        )

        expect {
          result =
            described_class.import(
              "Negroni"
            )

          expect(result).to eq(
            cached_fact
          )
        }.not_to change(
          FunFact,
          :count
        )
      end
    end

    context "sad path" do
      it "returns nil when Wikipedia does not find a matching page" do
        expect(
          WikimediaGateway
        ).to receive(
          :search_page
        ).with(
          "Fake Drink cocktail"
        ).and_return(
          {
            pages: []
          }
        )

        expect(
          WikimediaGateway
        ).not_to receive(
          :fetch_extract
        )

        expect {
          result =
            described_class.import(
              "Fake Drink"
            )

          expect(result).to be_nil
        }.not_to change(
          FunFact,
          :count
        )
      end

      it "skips a Wikipedia result that is not about a drink" do
        expect(
          WikimediaGateway
        ).to receive(
          :search_page
        ).with(
          "Cocktail 2 cocktail"
        ).and_return(
          {
            pages: [
              {
                title: "Cocktail 2",
                description:
                  "2026 Indian Hindi-language romantic comedy drama film"
              }
            ]
          }
        )

        expect(
          WikimediaGateway
        ).not_to receive(
          :fetch_extract
        )

        expect {
          result =
            described_class.import(
              "Cocktail 2"
            )

          expect(result).to be_nil
        }.not_to change(
          FunFact,
          :count
        )
      end

      it "returns nil when a drink article has no extract" do
        expect(
          WikimediaGateway
        ).to receive(
          :search_page
        ).with(
          "Fake Drink cocktail"
        ).and_return(
          {
            pages: [
              {
                title: "Fake Drink",
                description:
                  "Mixed drink cocktail"
              }
            ]
          }
        )

        expect(
          WikimediaGateway
        ).to receive(
          :fetch_extract
        ).with(
          "Fake Drink"
        ).and_return(
          {
            query: {
              pages: []
            }
          }
        )

        expect {
          result =
            described_class.import(
              "Fake Drink"
            )

          expect(result).to be_nil
        }.not_to change(
          FunFact,
          :count
        )
      end

      it "returns nil when a drink article has a blank extract" do
        expect(
          WikimediaGateway
        ).to receive(
          :search_page
        ).with(
          "Fake Drink cocktail"
        ).and_return(
          {
            pages: [
              {
                title: "Fake Drink",
                description:
                  "Alcoholic drink"
              }
            ]
          }
        )

        expect(
          WikimediaGateway
        ).to receive(
          :fetch_extract
        ).with(
          "Fake Drink"
        ).and_return(
          {
            query: {
              pages: [
                {
                  title: "Fake Drink",
                  extract: ""
                }
              ]
            }
          }
        )

        expect {
          result =
            described_class.import(
              "Fake Drink"
            )

          expect(result).to be_nil
        }.not_to change(
          FunFact,
          :count
        )
      end
    end
  end
end