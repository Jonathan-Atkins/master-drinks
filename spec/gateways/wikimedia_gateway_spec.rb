require "rails_helper"

RSpec.describe WikimediaGateway do
  describe ".search_page" do
    context "happy path" do
      it "returns parsed Wikipedia search results" do
        connection = instance_double(
          Faraday::Connection
        )

        response = instance_double(
          Faraday::Response,
          success?: true,
          body: {
            pages: [
              {
                title: "Negroni",
                description: "Italian cocktail"
              }
            ]
          }.to_json
        )

        allow(Faraday)
          .to receive(:new)
          .and_return(connection)

        expect(connection)
          .to receive(:get)
          .with(
            "/w/rest.php/v1/search/page",
            {
              q: "Negroni cocktail",
              limit: 1
            }
          )
          .and_return(response)

        result =
          described_class.search_page(
            "Negroni cocktail"
          )

        expect(result).to eq(
          {
            pages: [
              {
                title: "Negroni",
                description: "Italian cocktail"
              }
            ]
          }
        )
      end

      it "configures the Wikimedia connection" do
        connection =
          described_class.send(:connection)

        expect(
          connection.headers["User-Agent"]
        ).to eq("BarBuddy/1.0")

        expect(
          connection.options.open_timeout
        ).to eq(2)

        expect(
          connection.options.timeout
        ).to eq(5)
      end
    end

    context "sad path" do
      it "returns an empty search response for an unsuccessful request" do
        connection = instance_double(
          Faraday::Connection
        )

        response = instance_double(
          Faraday::Response,
          success?: false
        )

        allow(Faraday)
          .to receive(:new)
          .and_return(connection)

        allow(connection)
          .to receive(:get)
          .and_return(response)

        result =
          described_class.search_page(
            "Negroni cocktail"
          )

        expect(result).to eq(
          {
            pages: []
          }
        )
      end

      it "returns an empty search response when Wikimedia times out" do
        connection = instance_double(
          Faraday::Connection
        )

        allow(Faraday)
          .to receive(:new)
          .and_return(connection)

        allow(connection)
          .to receive(:get)
          .and_raise(
            Faraday::TimeoutError
          )

        result =
          described_class.search_page(
            "Negroni cocktail"
          )

        expect(result).to eq(
          {
            pages: []
          }
        )
      end

      it "returns an empty search response when Wikimedia cannot connect" do
        connection = instance_double(
          Faraday::Connection
        )

        allow(Faraday)
          .to receive(:new)
          .and_return(connection)

        allow(connection)
          .to receive(:get)
          .and_raise(
            Faraday::ConnectionFailed.new(
              "Connection failed"
            )
          )

        result =
          described_class.search_page(
            "Negroni cocktail"
          )

        expect(result).to eq(
          {
            pages: []
          }
        )
      end

      it "returns an empty search response for invalid JSON" do
        connection = instance_double(
          Faraday::Connection
        )

        response = instance_double(
          Faraday::Response,
          success?: true,
          body: "invalid-json"
        )

        allow(Faraday)
          .to receive(:new)
          .and_return(connection)

        allow(connection)
          .to receive(:get)
          .and_return(response)

        result =
          described_class.search_page(
            "Negroni cocktail"
          )

        expect(result).to eq(
          {
            pages: []
          }
        )
      end
    end
  end

  describe ".fetch_extract" do
    context "happy path" do
      it "returns the full introductory extract for a Wikipedia article" do
        connection = instance_double(
          Faraday::Connection
        )

        response = instance_double(
          Faraday::Response,
          success?: true,
          body: {
            query: {
              pages: [
                {
                  title: "Margarita",
                  extract:
                    "A margarita is a cocktail of tequila, triple sec, lime juice, and sometimes simple syrup. It can be served shaken, straight up, or frozen."
                }
              ]
            }
          }.to_json
        )

        allow(Faraday)
          .to receive(:new)
          .and_return(connection)

        expect(connection)
          .to receive(:get)
          .with(
            "/w/api.php",
            {
              action: "query",
              prop: "extracts",
              exintro: 1,
              explaintext: 1,
              redirects: 1,
              titles: "Margarita",
              format: "json",
              formatversion: 2
            }
          )
          .and_return(response)

        result =
          described_class.fetch_extract(
            "Margarita"
          )

        expect(
          result.dig(
            :query,
            :pages,
            0,
            :extract
          )
        ).to include(
          "A margarita is a cocktail"
        )
      end
    end

    context "sad path" do
      it "returns an empty extract response for an unsuccessful request" do
        connection = instance_double(
          Faraday::Connection
        )

        response = instance_double(
          Faraday::Response,
          success?: false
        )

        allow(Faraday)
          .to receive(:new)
          .and_return(connection)

        allow(connection)
          .to receive(:get)
          .and_return(response)

        result =
          described_class.fetch_extract(
            "Margarita"
          )

        expect(result).to eq(
          {
            query: {
              pages: []
            }
          }
        )
      end

      it "returns an empty extract response when Wikimedia times out" do
        connection = instance_double(
          Faraday::Connection
        )

        allow(Faraday)
          .to receive(:new)
          .and_return(connection)

        allow(connection)
          .to receive(:get)
          .and_raise(
            Faraday::TimeoutError
          )

        result =
          described_class.fetch_extract(
            "Margarita"
          )

        expect(result).to eq(
          {
            query: {
              pages: []
            }
          }
        )
      end

      it "returns an empty extract response when Wikimedia cannot connect" do
        connection = instance_double(
          Faraday::Connection
        )

        allow(Faraday)
          .to receive(:new)
          .and_return(connection)

        allow(connection)
          .to receive(:get)
          .and_raise(
            Faraday::ConnectionFailed.new(
              "Connection failed"
            )
          )

        result =
          described_class.fetch_extract(
            "Margarita"
          )

        expect(result).to eq(
          {
            query: {
              pages: []
            }
          }
        )
      end

      it "returns an empty extract response for invalid JSON" do
        connection = instance_double(
          Faraday::Connection
        )

        response = instance_double(
          Faraday::Response,
          success?: true,
          body: "invalid-json"
        )

        allow(Faraday)
          .to receive(:new)
          .and_return(connection)

        allow(connection)
          .to receive(:get)
          .and_return(response)

        result =
          described_class.fetch_extract(
            "Margarita"
          )

        expect(result).to eq(
          {
            query: {
              pages: []
            }
          }
        )
      end
    end
  end
end
