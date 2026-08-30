class WikimediaFactPoro
  attr_reader :title, :summary, :source_url

  def initialize(data)
    page = data[:pages].first

    @title = page[:title]
    @summary = page[:description]
    @source_url = "#{WikimediaGateway::BASE_URL}/wiki/#{page[:key]}"
  end
end
