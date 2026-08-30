class WikimediaFactImporter
  def self.import(topic)
    data = WikimediaGateway.search_page(topic)

    fact = WikimediaFactPoro.new(data)

    FunFact.create!(
      body: fact.summary,
      source_name: "Wikipedia",
      source_url: fact.source_url,
      category: "cocktail-history",
    )
  end
end
