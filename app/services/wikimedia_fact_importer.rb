class WikimediaFactImporter
  def self.import(topic)
    cached_fact = FunFact.find_by(drink_name: topic)

    return cached_fact if cached_fact

    data = WikimediaGateway.search_page(topic)
    fact = WikimediaFactPoro.new(data)

    return nil if fact.summary.blank?

    FunFact.create!(
      body: fact.summary,
      drink_name: topic
    )
  end
end
