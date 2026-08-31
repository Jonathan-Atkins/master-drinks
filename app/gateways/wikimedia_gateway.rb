require "faraday"
require "json"

class WikimediaGateway
  BASE_URL = "https://en.wikipedia.org".freeze

  def self.search_page(topic)
    response = connection.get(
      "/w/rest.php/v1/search/page",
      {
        q: topic,
        limit: 1
      }
    )

    return empty_response unless response.success?

    JSON.parse(
      response.body,
      symbolize_names: true
    )
  rescue Faraday::TimeoutError,
         Faraday::ConnectionFailed,
         JSON::ParserError
    empty_response
  end

  def self.connection
    Faraday.new(
      url: BASE_URL,
      headers: {
        "User-Agent" => "BarBuddy/1.0"
      }
    ) do |faraday|
      faraday.options.open_timeout = 2
      faraday.options.timeout = 5
    end
  end

  def self.empty_response
    {
      pages: []
    }
  end

  private_class_method :connection, :empty_response
end
