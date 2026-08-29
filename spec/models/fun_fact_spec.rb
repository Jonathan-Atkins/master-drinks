require "rails_helper"

RSpec.describe FunFact, type: :model do
  describe "validations" do
    it "is valid with all required attributes" do
      fun_fact = FunFact.new(
        body: "The Negroni is associated with Florence, Italy.",
        source_name: "Wikipedia",
        source_url: "https://en.wikipedia.org/wiki/Negroni",
        category: "cocktail-history"
      )

      expect(fun_fact).to be_valid
    end

    it "is invalid without a body" do
      fun_fact = FunFact.new(
        source_name: "Wikipedia",
        source_url: "https://en.wikipedia.org/wiki/Negroni",
        category: "cocktail-history"
      )

      expect(fun_fact).not_to be_valid
    end

    it "is invalid without a source name" do
      fun_fact = FunFact.new(
        body: "The Negroni is associated with Florence, Italy.",
        source_url: "https://en.wikipedia.org/wiki/Negroni",
        category: "cocktail-history"
      )

      expect(fun_fact).not_to be_valid
    end

    it "is invalid without a source URL" do
      fun_fact = FunFact.new(
        body: "The Negroni is associated with Florence, Italy.",
        source_name: "Wikipedia",
        category: "cocktail-history"
      )

      expect(fun_fact).not_to be_valid
    end

    it "is invalid without a category" do
      fun_fact = FunFact.new(
        body: "The Negroni is associated with Florence, Italy.",
        source_name: "Wikipedia",
        source_url: "https://en.wikipedia.org/wiki/Negroni"
      )

      expect(fun_fact).not_to be_valid
    end
  end
end