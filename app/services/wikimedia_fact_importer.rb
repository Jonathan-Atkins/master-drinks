class WikimediaFactImporter
  DRINK_CONTEXT_TERMS = [
    "cocktail",
    "mixed drink",
    "alcoholic drink",
    "non-alcoholic drink",
    "mocktail",
    "beverage"
  ].freeze

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
    return nil unless drink_related?(page)

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

  def self.drink_related?(page)
    description =
      page[:description]
        .to_s
        .downcase

    DRINK_CONTEXT_TERMS.any? do |term|
      description.include?(term)
    end
  end

  private_class_method :drink_related?
end
