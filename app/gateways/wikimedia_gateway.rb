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

    JSON.parse(
      response.body,
      symbolize_names: true
    )
  end

  def self.connection
    Faraday.new(url: BASE_URL)
  end

  private_class_method :connection
end