require "rails_helper"

RSpec.describe Drink, type: :model do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "AliceInWonderLand",
      email: "alice@email.com",
      password: "12345",
      password_confirmation: "12345",
    )
  end

  describe "validations" do
    describe "happy path" do
      it "is valid with valid attributes" do
        drink = @user.drinks.new(
          name: "Mojito",
          category: "Rum",
          alcoholic: true,
        )

        expect(drink).to be_valid
      end

      it "is valid when alcoholic is false" do
        drink = @user.drinks.new(
          name: "Virgin Mojito",
          category: "Non_Alcoholic",
          alcoholic: false,
        )

        expect(drink).to be_valid
      end
    end

    describe "sad path" do
      it "is invalid without a name" do
        drink = @user.drinks.new(
          name: nil,
          category: "Rum",
          alcoholic: true,
        )

        expect(drink).not_to be_valid
        expect(drink.errors[:name]).to include("can't be blank")
      end

      it "is invalid with an exact duplicate name" do
        @user.drinks.create!(
          name: "Mojito",
          category: "Rum",
          alcoholic: true,
        )

        drink = @user.drinks.new(
          name: "Mojito",
          category: "Rum",
          alcoholic: true,
        )

        expect(drink).not_to be_valid
        expect(drink.errors[:name]).to include("has already been taken")
      end

      it "is invalid with a case-insensitive duplicate name" do
        @user.drinks.create!(
          name: "Old Fashioned",
          category: "Whiskey",
          alcoholic: true,
        )

        drink = @user.drinks.new(
          name: "old fashioned",
          category: "Bourbon",
          alcoholic: true,
        )

        expect(drink).not_to be_valid
        expect(drink.errors[:name]).to include("has already been taken")
      end

      it "does not allow another user to create the same drink name" do
        other_user = User.create!(
          name: "Bob",
          username: "BobTheBuilder",
          email: "bob@email.com",
          password: "12345",
          password_confirmation: "12345",
        )

        @user.drinks.create!(
          name: "Old Fashioned",
          category: "Whiskey",
          alcoholic: true,
        )

        duplicate = other_user.drinks.new(
          name: "OLD FASHIONED",
          category: "Bourbon",
          alcoholic: true,
        )

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include("has already been taken")
      end

      it "is invalid without a category" do
        drink = @user.drinks.new(
          name: "Mojito",
          category: nil,
          alcoholic: true,
        )

        expect(drink).not_to be_valid
        expect(drink.errors[:category]).to include("can't be blank")
      end

      it "is invalid with an unsupported category" do
        drink = @user.drinks.new(
          name: "Milkshake",
          category: "Milkshake",
          alcoholic: true,
        )

        expect(drink).not_to be_valid
        expect(drink.errors[:category]).to include(
          "is not included in the list"
        )
      end

      it "is invalid without alcoholic status" do
        drink = @user.drinks.new(
          name: "Mojito",
          category: "Rum",
          alcoholic: nil,
        )

        expect(drink).not_to be_valid
        expect(drink.errors[:alcoholic]).to include(
          "is not included in the list"
        )
      end

      it "is invalid without a user" do
        drink = Drink.new(
          name: "Mojito",
          category: "Rum",
          alcoholic: true,
        )

        expect(drink).not_to be_valid
        expect(drink.errors[:user]).to include("must exist")
      end
    end
  end

  describe "normalization" do
    describe "happy path" do
      it "normalizes category before validation" do
        drink = @user.drinks.new(
          name: "Mojito",
          category: "rum",
          alcoholic: true,
        )

        drink.valid?

        expect(drink.category).to eq("Rum")
      end

      it "removes surrounding whitespace from the name" do
        drink = @user.drinks.new(
          name: "  Old Fashioned  ",
          category: "Whiskey",
          alcoholic: true,
        )

        drink.valid?

        expect(drink.name).to eq("Old Fashioned")
      end

      it "removes repeated whitespace from the name" do
        drink = @user.drinks.new(
          name: "Old    Fashioned",
          category: "Whiskey",
          alcoholic: true,
        )

        drink.valid?

        expect(drink.name).to eq("Old Fashioned")
      end
    end
  end

  describe ".sorted_by" do
    before(:each) do
      @daiquiri = @user.drinks.create!(
        name: "Daiquiri",
        category: "Rum",
        alcoholic: true,
      )

      @margarita = @user.drinks.create!(
        name: "Margarita",
        category: "Tequila",
        alcoholic: true,
      )

      @old_fashioned = @user.drinks.create!(
        name: "Old Fashioned",
        category: "Whiskey",
        alcoholic: true,
      )

      @daiquiri.update_columns(
        created_at: 3.days.ago,
        updated_at: 3.days.ago,
      )

      @margarita.update_columns(
        created_at: 2.days.ago,
        updated_at: 2.days.ago,
      )

      @old_fashioned.update_columns(
        created_at: 1.day.ago,
        updated_at: 1.day.ago,
      )
    end

    describe "happy path" do
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
          "Rum",
          "Tequila",
          "Whiskey"
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
    end

    describe "sad path" do
      it "returns all drinks when the sort option is not recognized" do
        drinks = Drink.sorted_by("random")

        expect(drinks).to contain_exactly(
          @daiquiri,
          @margarita,
          @old_fashioned
        )
      end
    end
  end

  describe "relationships" do
    describe "happy path" do
      it "belongs to a user" do
        drink = @user.drinks.create!(
          name: "Mojito",
          category: "Rum",
          alcoholic: true,
        )

        expect(drink.user).to eq(@user)
      end

      it "has many recipes" do
        drink = @user.drinks.create!(
          name: "Old Fashioned",
          category: "Whiskey",
          alcoholic: true,
        )

        recipe1 = Recipe.create!(
          drink: drink,
          name: "Classic Old Fashioned",
          instructions: "Stir with ice.",
        )

        recipe2 = Recipe.create!(
          drink: drink,
          name: "Maple Old Fashioned",
          instructions: "Stir with maple syrup and ice.",
        )

        expect(drink.recipes).to contain_exactly(recipe1, recipe2)
      end

      it "destroys its recipes when the drink is destroyed" do
        drink = @user.drinks.create!(
          name: "Old Fashioned",
          category: "Whiskey",
          alcoholic: true,
        )

        recipe = Recipe.create!(
          drink: drink,
          name: "Classic Old Fashioned",
          instructions: "Stir with ice.",
        )

        drink.destroy

        expect(Recipe.exists?(recipe.id)).to be(false)
      end
    end
  end

  describe "visibility" do
    describe "happy path" do
      it "is publicly visible by default" do
        drink = @user.drinks.create!(
          name: "Old Fashioned",
          category: "Whiskey",
          alcoholic: true,
        )

        expect(drink.publicly_visible).to be(true)
      end

      it "returns only publicly visible drinks" do
        public_drink = @user.drinks.create!(
          name: "Old Fashioned",
          category: "Whiskey",
          alcoholic: true,
          publicly_visible: true,
        )

        private_drink = @user.drinks.create!(
          name: "Private Margarita",
          category: "Tequila",
          alcoholic: true,
          publicly_visible: false,
        )

        result = Drink.publicly_visible

        expect(result).to include(public_drink)
        expect(result).not_to include(private_drink)
      end
    end
  end
end
