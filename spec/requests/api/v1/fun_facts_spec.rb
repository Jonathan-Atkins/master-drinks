require "rails_helper"

RSpec.describe "FunFacts API", type: :request do
  describe "GET /api/v1/fun_facts" do
    describe "happy path" do
      it "returns a fun fact built from a public drink" do
        category =
          create_category(
            "Gin",
            alcoholic: true
          )

        user = User.create!(
          name: "Alice",
          username: "alice",
          email: "alice@example.com",
          password: "12345",
          password_confirmation: "12345"
        )

        Drink.create!(
          user: user,
          name: "Negroni",
          alcoholic: true,
          publicly_visible: true,
          categories: [ category ]
        )

        search_data = {
          pages: [
            {
              key: "Negroni",
              title: "Negroni",
              description: "Italian cocktail",
              excerpt:
                "The Negroni is an Italian cocktail."
            }
          ]
        }

        extract_data = {
          query: {
            pages: [
              {
                title: "Negroni",
                extract:
                  "A Negroni is an Italian cocktail made with gin, vermouth, and Campari."
              }
            ]
          }
        }

        allow(WikimediaGateway)
          .to receive(:search_page)
          .with("Negroni cocktail")
          .and_return(search_data)

        allow(WikimediaGateway)
          .to receive(:fetch_extract)
          .with("Negroni")
          .and_return(extract_data)

        get "/api/v1/fun_facts"

        expect(response).to have_http_status(:ok)

        data = JSON.parse(
          response.body,
          symbolize_names: true
        )

        expect(data.count).to eq(1)

        expect(data.first[:body]).to eq(
          "A Negroni is an Italian cocktail made with gin, vermouth, and Campari."
        )

        expect(data.first[:drink_name]).to eq(
          "Negroni"
        )

        expect(FunFact.count).to eq(1)
      end
    end

    describe "sad path" do
      it "returns an empty array when Wikimedia cannot find a fact" do
        category =
          create_category(
            "Gin",
            alcoholic: true
          )

        user = User.create!(
          name: "Alice",
          username: "alice",
          email: "alice@example.com",
          password: "12345",
          password_confirmation: "12345"
        )

        Drink.create!(
          user: user,
          name: "Jonathan's Fire Water",
          alcoholic: true,
          publicly_visible: true,
          categories: [ category ]
        )

        allow(WikimediaGateway)
          .to receive(:search_page)
          .with("Jonathan's Fire Water cocktail")
          .and_return(
            pages: []
          )

        expect(WikimediaGateway)
          .not_to receive(:fetch_extract)

        get "/api/v1/fun_facts"

        expect(response).to have_http_status(:ok)

        data = JSON.parse(response.body)

        expect(data).to eq([])
        expect(FunFact.count).to eq(0)
      end
    end
  end
end
