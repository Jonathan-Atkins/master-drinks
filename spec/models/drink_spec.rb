require "rails_helper"

RSpec.describe Drink, type: :model do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "AliceInWonderLand",
      email: "alice@email.com",
      password: "12345",
      password_confirmation: "12345"
    )
  end

  describe "validations" do
    describe "happy path" do
      it "is valid with valid attributes" do
        drink = create_drink(
          @user,
          {
            name: "Mojito",
            alcoholic: true
          },
          category_names: [ "Rum" ]
        )

        expect(drink).to be_valid
      end

      it "is valid when alcoholic is false" do
        drink = create_drink(
          @user,
          {
            name: "Virgin Mojito",
            alcoholic: false
          },
          category_names: [ "Non Alcoholic" ]
        )

        expect(drink).to be_valid
      end

      it "allows different users to create the same drink name" do
        other_user = User.create!(
          name: "Bob",
          username: "BobTheBuilder",
          email: "bob@email.com",
          password: "12345",
          password_confirmation: "12345"
        )

        create_drink(
          @user,
          {
            name: "Old Fashioned",
            alcoholic: true
          },
          category_names: [ "Whiskey" ]
        )

        drink = other_user.drinks.new(
          name: "OLD FASHIONED",
          alcoholic: true
        )

        drink.categories = [
          create_category("Bourbon")
        ]

        expect(drink).to be_valid
      end
    end

    describe "sad path" do
      it "is invalid without a name" do
        drink = @user.drinks.new(
          name: nil,
          alcoholic: true
        )

        drink.categories = [
          create_category("Rum")
        ]

        expect(drink).not_to be_valid
        expect(drink.errors[:name]).to include(
          "can't be blank"
        )
      end

      it "is invalid with an exact duplicate name for the same user" do
        create_drink(
          @user,
          {
            name: "Mojito",
            alcoholic: true
          },
          category_names: [ "Rum" ]
        )

        drink = @user.drinks.new(
          name: "Mojito",
          alcoholic: true
        )

        drink.categories = [
          create_category("Rum")
        ]

        expect(drink).not_to be_valid
        expect(drink.errors[:name]).to include(
          "has already been taken"
        )
      end

      it "is invalid with a case-insensitive duplicate name for the same user" do
        create_drink(
          @user,
          {
            name: "Old Fashioned",
            alcoholic: true
          },
          category_names: [ "Whiskey" ]
        )

        drink = @user.drinks.new(
          name: "old fashioned",
          alcoholic: true
        )

        drink.categories = [
          create_category("Bourbon")
        ]

        expect(drink).not_to be_valid
        expect(drink.errors[:name]).to include(
          "has already been taken"
        )
      end

      it "is invalid without categories" do
        drink = @user.drinks.new(
          name: "Mojito",
          alcoholic: true
        )

        expect(drink).not_to be_valid
        expect(drink.errors[:categories]).to include(
          "must include at least one category"
        )
      end

      it "is invalid without alcoholic status" do
        drink = @user.drinks.new(
          name: "Mojito",
          alcoholic: nil
        )

        drink.categories = [
          create_category("Rum")
        ]

        expect(drink).not_to be_valid
        expect(drink.errors[:alcoholic]).to include(
          "is not included in the list"
        )
      end

      it "is invalid without a user" do
        drink = Drink.new(
          name: "Mojito",
          alcoholic: true
        )

        drink.categories = [
          create_category("Rum")
        ]

        expect(drink).not_to be_valid
        expect(drink.errors[:user]).to include(
          "must exist"
        )
      end
    end
  end

  describe ".sorted_by" do
    before(:each) do
      @daiquiri = create_drink(
        @user,
        {
          name: "Daiquiri",
          alcoholic: true
        },
        category_names: [ "Rum" ]
      )

      @margarita = create_drink(
        @user,
        {
          name: "Margarita",
          alcoholic: true
        },
        category_names: [ "Tequila" ]
      )

      @old_fashioned = create_drink(
        @user,
        {
          name: "Old Fashioned",
          alcoholic: true
        },
        category_names: [ "Whiskey" ]
      )

      @daiquiri.update_columns(
        created_at: 3.days.ago,
        updated_at: 3.days.ago
      )

      @margarita.update_columns(
        created_at: 2.days.ago,
        updated_at: 2.days.ago
      )

      @old_fashioned.update_columns(
        created_at: 1.day.ago,
        updated_at: 1.day.ago
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
        drink = create_drink(
          @user,
          {
            name: "Mojito",
            alcoholic: true
          },
          category_names: [ "Rum" ]
        )

        expect(drink.user).to eq(@user)
      end

      it "has many recipes" do
        drink = create_drink(
          @user,
          {
            name: "Old Fashioned",
            alcoholic: true
          },
          category_names: [ "Whiskey" ]
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

        expect(drink.recipes).to contain_exactly(
          recipe1,
          recipe2
        )
      end

      it "destroys its recipes when the drink is destroyed" do
        drink = create_drink(
          @user,
          {
            name: "Old Fashioned",
            alcoholic: true
          },
          category_names: [ "Whiskey" ]
        )

        recipe = Recipe.create!(
          drink: drink,
          name: "Classic Old Fashioned",
          instructions: "Stir with ice."
        )

        drink.destroy

        expect(
          Recipe.exists?(recipe.id)
        ).to be(false)
      end
    end
  end

  describe "visibility" do
    describe "happy path" do
      it "is publicly visible by default" do
        drink = create_drink(
          @user,
          {
            name: "Old Fashioned",
            alcoholic: true
          },
          category_names: [ "Whiskey" ]
        )

        expect(
          drink.publicly_visible
        ).to be(true)
      end

      it "returns only publicly visible drinks" do
        public_drink = create_drink(
          @user,
          {
            name: "Old Fashioned",
            alcoholic: true,
            publicly_visible: true
          },
          category_names: [ "Whiskey" ]
        )

        private_drink = create_drink(
          @user,
          {
            name: "Private Margarita",
            alcoholic: true,
            publicly_visible: false
          },
          category_names: [ "Tequila" ]
        )

        result = Drink.publicly_visible

        expect(result).to include(public_drink)
        expect(result).not_to include(private_drink)
      end
    end
  end

  it "has many drink_categories" do
    association =
      described_class.reflect_on_association(
        :drink_categories
      )

    expect(association.macro).to eq(:has_many)
  end

  it "has many categories through drink_categories" do
    association =
      described_class.reflect_on_association(
        :categories
      )

    expect(association.macro).to eq(:has_many)

    expect(
      association.options[:through]
    ).to eq(:drink_categories)
  end

  it "supports multiple categories" do
    drink = create_drink(
      @user,
      {},
      category_names: [ "Rum", "Gin" ]
    )

    expect(
      drink.categories.pluck(:name)
    ).to contain_exactly(
      "Rum",
      "Gin"
    )
  end
end
