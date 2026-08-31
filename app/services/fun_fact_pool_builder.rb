class FunFactPoolBuilder
  POOL_SIZE = 20

  def self.call
    drink_names = Drink.publicly_visible
      .pluck(:name)
      .uniq { |name| name.downcase }
      .shuffle

    facts = []

    drink_names.each do |drink_name|
      break if facts.size >= POOL_SIZE

      fact = WikimediaFactImporter.import(drink_name)

      facts << fact if fact.present?
    end

    facts.shuffle
  end
end
