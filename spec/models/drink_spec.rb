require "rails_helper"

RSpec.describe Drink, type: :model do
  describe "validations" do
    describe "valid attributes" do
      it "is valid with valid attributes" do
        drink = Drink.new(name: "Mojito", category: "rum", alcoholic: true)

        expect(drink).to be_valid
      end

      it "is valid when alcoholic is false" do
        drink = Drink.new(name: "Virgin Mojito", category: "non_spirit", alcoholic: false)

        expect(drink).to be_valid
      end
    end

    describe "invalid attributes" do
      it "is invalid without a name" do
        drink = Drink.new(name: nil, category: "rum", alcoholic: true)

        expect(drink).not_to be_valid
      end

      it "is invalid with a duplicate name" do
        Drink.create!(name: "Mojito", category: "rum", alcoholic: true)

        drink = Drink.new(name: "Mojito", category: "rum", alcoholic: true)

        expect(drink).not_to be_valid
        expect(drink.errors[:name]).to include("has already been taken")
      end

      it "is invalid without a category" do
        drink = Drink.new(name: "Mojito", category: nil, alcoholic: true)

        expect(drink).not_to be_valid
      end

      it "is invalid with an unsupported category" do
        drink = Drink.new(name: "Milkshake", category: "milkshake", alcoholic: true)

        expect(drink).not_to be_valid
        expect(drink.errors[:category]).to include("is not included in the list")
      end

      it "is invalid without alcoholic status" do
        drink = Drink.new(name: "Mojito", category: "rum", alcoholic: nil)

        expect(drink).not_to be_valid
      end
    end
  end

  describe "category normalization" do
    it "normalizes category before validation" do
      drink = Drink.new(name: "Mojito", category: "Rum", alcoholic: true)

      drink.valid?

      expect(drink.category).to eq("rum")
    end
  end

  describe ".sorted_by" do
    before(:each) do
      Drink.destroy_all

      @daiquiri = Drink.create!(name: "Daiquiri", category: "rum", alcoholic: true)
      @margarita = Drink.create!(name: "Margarita", category: "tequila", alcoholic: true)
      @old_fashioned = Drink.create!(name: "Old Fashioned", category: "whiskey", alcoholic: true)

      @daiquiri.update_columns(created_at: 3.days.ago, updated_at: 3.days.ago)
      @margarita.update_columns(created_at: 2.days.ago, updated_at: 2.days.ago)
      @old_fashioned.update_columns(created_at: 1.day.ago, updated_at: 1.day.ago)
    end

    it "sorts by name alphabetically" do
      drinks = Drink.sorted_by("name")

      expect(drinks.map(&:name)).to eq([
        "Daiquiri",
        "Margarita",
        "Old Fashioned"
      ])
    end

    it "sorts by category alphabetically" do
      drinks = Drink.sorted_by("category")

      expect(drinks.map(&:category)).to eq([
        "rum",
        "tequila",
        "whiskey"
      ])
    end

    it "sorts by date added with newest first" do
      drinks = Drink.sorted_by("date_added")

      expect(drinks.map(&:name)).to eq([
        "Old Fashioned",
        "Margarita",
        "Daiquiri"
      ])
    end

    it "sorts by date edited with most recently edited first" do
      drinks = Drink.sorted_by("date_edited")

      expect(drinks.map(&:name)).to eq([
        "Old Fashioned",
        "Margarita",
        "Daiquiri"
      ])
    end

    it "returns all drinks when sort option is not recognized" do
      drinks = Drink.sorted_by("random")

      expect(drinks.count).to eq(3)
    end
  end
  
  describe "relationships" do
    it "has many recipes" do
      drink = Drink.create!(
        name: "Old Fashioned",
        category: "whiskey",
        alcoholic: true
        )

      recipe1 = Recipe.create!(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir with ice."
      )

      recipe2 = Recipe.create!(
        drink: drink,
        name: "Maple Old Fashioned",
        instructions: "Stir with maple syrup and ice."
      )

      expect(drink.recipes).to contain_exactly(recipe1, recipe2)
    end
    it "destroys its recipes when the drink is destroyed" do
      drink = Drink.create!(
        name: "Old Fashioned",
        category: "whiskey",
        alcoholic: true
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir with ice."
      )
      
      drink.destroy
      
      expect(Recipe.exists?(recipe.id)).to eq(false)
    end
  end
end
