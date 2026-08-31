class WikimediaFactPoro
  attr_reader :summary

  def initialize(data)
    page = data[:pages]&.first

    @summary = page&.dig(:description)
  end
end
