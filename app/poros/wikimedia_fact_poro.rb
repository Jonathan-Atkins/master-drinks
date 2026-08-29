class WikimediaFactPoro
  attr_reader :title, :summary, :source_url

  def initialize(data)
    @title = data[:title]
    @summary = data[:extract]
    @source_url = data.dig(
      :content_urls,
      :desktop,
      :page
    )
  end
end