class WikimediaFactImporter
  def self.import(topic)
    data = WikimediaGateway.get_summary(topic)

    fact = WikimediaFactPoro.new(data)

    FunFact.create!(
      body: fact.summary,
      source_name: "Wikipedia",
      source_url: fact.source_url,
      category: "cocktail-history"
    )
  end
end