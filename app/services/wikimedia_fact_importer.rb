class WikimediaFactImporter
  def self.import(topic)
    cached_fact = FunFact.find_by(
      drink_name: topic
    )

    return cached_fact if cached_fact

    search_data =
      WikimediaGateway.search_page(
        "#{topic} cocktail"
      )

    page = search_data[:pages]&.first

    return nil unless page

    title = page[:title]

    extract_data =
      WikimediaGateway.fetch_extract(title)

    extract =
      extract_data.dig(
        :query,
        :pages,
        0,
        :extract
      )

    return nil if extract.blank?

    FunFact.create!(
      body: extract,
      drink_name: topic
    )
  end
end
