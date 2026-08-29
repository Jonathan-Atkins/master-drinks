# app/gateways/wikimedia_gateway.rb

class WikimediaGateway
  BASE_URL = "https://en.wikipedia.org".freeze

  def self.get_summary(topic)
    response = connection.get(
      "/api/rest_v1/page/summary/#{URI.encode_www_form_component(topic)}"
    )

    JSON.parse(response.body, symbolize_names: true)
  end

  def self.connection
    Faraday.new(url: BASE_URL)
  end

  private_class_method :connection
end