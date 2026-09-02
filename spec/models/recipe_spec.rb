require "rails_helper"

RSpec.describe Recipe, type: :model do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "AliceInWonderLand",
      email: "alice@email.com",
      password: "12345",
      password_confirmation: "12345"
    )
  end

  describe "relationships" do
    describe "happy path" do
      it "belongs to a drink" do
        drink = create_drink(
          @user,
          {
            name: "Old Fashioned",
            alcoholic: true
          },
          category_names: [
            "Whiskey"
          ]
        )

        recipe = create(
          :recipe,
          drink: drink,
          name:
            "Classic Old Fashioned"
        )

        expect(
          recipe.drink
        ).to eq(drink)
      end

      it "has many ingredients through recipe ingredients" do
        drink = create_drink(
          @user,
          {
            name: "Old Fashioned",
            alcoholic: true
          },
          category_names: [
            "Whiskey"
          ]
        )

        recipe = create(
          :recipe,
          drink: drink,
          name:
            "Classic Old Fashioned"
        )

        bourbon = create(
          :ingredient,
          name: "Bourbon",
          user: @user
        )

        bitters = create(
          :ingredient,
          name: "Bitters",
          user: @user,
          ingredient_type:
            "Bitters"
        )

        create(
          :recipe_ingredient,
          recipe: recipe,
          ingredient: bourbon,
          amount: 2,
          measurement_unit: "oz"
        )

        create(
          :recipe_ingredient,
          recipe: recipe,
          ingredient: bitters,
          amount: 2,
          measurement_unit:
            "dashes"
        )

        expect(
          recipe.ingredients
        ).to contain_exactly(
          bourbon,
          bitters
        )
      end

      it "destroys user recipes when the recipe is destroyed" do
        other_user = create(
          :user,
          username: "bob",
          email: "bob@example.com"
        )

        drink = create_drink(
          @user,
          {
            name: "Margarita",
            alcoholic: true
          },
          category_names: [
            "Tequila"
          ]
        )

        recipe = create(
          :recipe,
          drink: drink,
          name:
            "Classic Margarita"
        )

        user_recipe =
          UserRecipe.create!(
            user: other_user,
            recipe: recipe
          )

        recipe.destroy

        expect(
          UserRecipe.exists?(
            user_recipe.id
          )
        ).to be(false)

        expect(
          User.exists?(
            other_user.id
          )
        ).to be(true)
      end
    end
  end

  describe "validations" do
    describe "happy path" do
      it "is valid with valid attributes" do
        drink = create_drink(
          @user,
          {
            name: "Old Fashioned",
            alcoholic: true
          },
          category_names: [
            "Whiskey"
          ]
        )

        recipe = Recipe.new(
          drink: drink,
          name:
            "Classic Old Fashioned",
          instructions:
            "Stir ingredients with ice."
        )

        expect(recipe).to be_valid
      end

      it "automatically uses the drink name when the recipe name is blank" do
        drink = create_drink(
          @user,
          {
            name:
              "User's Specialty Drink",
            alcoholic: true
          },
          category_names: [
            "Gin"
          ]
        )

        recipe = Recipe.create!(
          drink: drink,
          name: nil,
          instructions:
            "Combine and serve."
        )

        expect(
          recipe.name
        ).to eq(
          "User's Specialty Drink"
        )
      end

      it "automatically adds (2) to the second unnamed recipe" do
        drink = create_drink(
          @user,
          {
            name: "Margarita",
            alcoholic: true
          },
          category_names: [
            "Tequila"
          ]
        )

        first_recipe =
          Recipe.create!(
            drink: drink,
            name: nil,
            instructions:
              "First recipe."
          )

        second_recipe =
          Recipe.create!(
            drink: drink,
            name: nil,
            instructions:
              "Second recipe."
          )

        expect(
          first_recipe.name
        ).to eq(
          "Margarita"
        )

        expect(
          second_recipe.name
        ).to eq(
          "Margarita (2)"
        )
      end

      it "increments automatically for additional unnamed recipes" do
        drink = create_drink(
          @user,
          {
            name: "Margarita",
            alcoholic: true
          },
          category_names: [
            "Tequila"
          ]
        )

        Recipe.create!(
          drink: drink,
          name: nil
        )

        Recipe.create!(
          drink: drink,
          name: nil
        )

        third_recipe =
          Recipe.create!(
            drink: drink,
            name: nil
          )

        expect(
          third_recipe.name
        ).to eq(
          "Margarita (3)"
        )
      end

      it "preserves an explicitly provided recipe name" do
        drink = create_drink(
          @user,
          {
            name: "Margarita",
            alcoholic: true
          },
          category_names: [
            "Tequila"
          ]
        )

        recipe = Recipe.create!(
          drink: drink,
          name:
            "Spicy Margarita"
        )

        expect(
          recipe.name
        ).to eq(
          "Spicy Margarita"
        )
      end

      it "allows the same recipe name under different drinks" do
        margarita = create_drink(
          @user,
          {
            name: "Margarita",
            alcoholic: true
          },
          category_names: [
            "Tequila"
          ]
        )

        mezcal_margarita =
          create_drink(
            @user,
            {
              name:
                "Mezcal Margarita",
              alcoholic: true
            },
            category_names: [
              "Mezcal"
            ]
          )

        create(
          :recipe,
          drink: margarita,
          name: "House Recipe"
        )

        recipe = build(
          :recipe,
          drink: mezcal_margarita,
          name: "House Recipe"
        )

        expect(recipe).to be_valid
      end

      it "normalizes extra whitespace in the recipe name" do
        drink = create_drink(
          @user,
          {
            name: "Margarita",
            alcoholic: true
          },
          category_names: [
            "Tequila"
          ]
        )

        recipe = Recipe.create!(
          drink: drink,
          name:
            "  Spicy   Margarita  "
        )

        expect(
          recipe.name
        ).to eq(
          "Spicy Margarita"
        )
      end
    end

    describe "sad path" do
      it "requires a drink" do
        recipe = Recipe.new(
          drink: nil,
          name:
            "Classic Old Fashioned",
          instructions:
            "Stir ingredients with ice."
        )

        expect(recipe).not_to be_valid

        expect(
          recipe.errors[:drink]
        ).to include(
          "must exist"
        )
      end

      it "does not allow an exact duplicate recipe name under the same drink" do
        drink = create_drink(
          @user,
          {
            name: "Margarita",
            alcoholic: true
          },
          category_names: [
            "Tequila"
          ]
        )

        create(
          :recipe,
          drink: drink,
          name:
            "Spicy Margarita"
        )

        duplicate = build(
          :recipe,
          drink: drink,
          name:
            "Spicy Margarita"
        )

        expect(
          duplicate
        ).not_to be_valid

        expect(
          duplicate.errors[:name]
        ).to include(
          "has already been taken"
        )
      end

      it "does not allow a case-insensitive duplicate recipe name under the same drink" do
        drink = create_drink(
          @user,
          {
            name: "Margarita",
            alcoholic: true
          },
          category_names: [
            "Tequila"
          ]
        )

        create(
          :recipe,
          drink: drink,
          name:
            "Spicy Margarita"
        )

        duplicate = build(
          :recipe,
          drink: drink,
          name:
            "SPICY MARGARITA"
        )

        expect(
          duplicate
        ).not_to be_valid

        expect(
          duplicate.errors[:name]
        ).to include(
          "has already been taken"
        )
      end
    end
  end

  describe "class methods" do
    before(:each) do
      @whiskey_drink =
        create_drink(
          @user,
          {
            name:
              "Old Fashioned",
            alcoholic: true
          },
          category_names: [
            "Whiskey"
          ]
        )

      @tequila_drink =
        create_drink(
          @user,
          {
            name: "Margarita",
            alcoholic: true
          },
          category_names: [
            "Tequila"
          ]
        )

      @old_fashioned_recipe =
        create(
          :recipe,
          drink:
            @whiskey_drink,
          name:
            "Classic Old Fashioned"
        )

      @maple_old_fashioned_recipe =
        create(
          :recipe,
          drink:
            @whiskey_drink,
          name:
            "Maple Old Fashioned"
        )

      @margarita_recipe =
        create(
          :recipe,
          drink:
            @tequila_drink,
          name:
            "Classic Margarita"
        )
    end

    describe ".by_drink_id" do
      it "returns recipes associated with a specific drink id" do
        result =
          Recipe.by_drink_id(
            @whiskey_drink.id
          )

        expect(
          result
        ).to contain_exactly(
          @old_fashioned_recipe,
          @maple_old_fashioned_recipe
        )

        expect(result).not_to include(
          @margarita_recipe
        )
      end
    end

    describe ".by_drink_name" do
      it "returns recipes associated with drinks matching the searched name" do
        result =
          Recipe.by_drink_name(
            "old fashioned"
          )

        expect(
          result
        ).to contain_exactly(
          @old_fashioned_recipe,
          @maple_old_fashioned_recipe
        )

        expect(result).not_to include(
          @margarita_recipe
        )
      end

      it "searches without being case sensitive" do
        result =
          Recipe.by_drink_name(
            "OLD FASHIONED"
          )

        expect(
          result
        ).to contain_exactly(
          @old_fashioned_recipe,
          @maple_old_fashioned_recipe
        )

        expect(result).not_to include(
          @margarita_recipe
        )
      end
    end

    describe ".search" do
      it "searches by drink name when drink_name is provided" do
        result =
          Recipe.search(
            drink_name:
              "old fashioned"
          )

        expect(
          result
        ).to contain_exactly(
          @old_fashioned_recipe,
          @maple_old_fashioned_recipe
        )

        expect(result).not_to include(
          @margarita_recipe
        )
      end

      it "returns all recipes when no search params are provided" do
        result =
          Recipe.search({})

        expect(
          result
        ).to contain_exactly(
          @old_fashioned_recipe,
          @maple_old_fashioned_recipe,
          @margarita_recipe
        )
      end
    end

    describe ".search_and_filter" do
      it "returns only publicly visible recipes" do
        private_recipe =
          create(
            :recipe,
            drink:
              @whiskey_drink,
            name:
              "Private Old Fashioned",
            publicly_visible:
              false
          )

        result =
          Recipe.search_and_filter(
            {}
          )

        expect(result).to include(
          @old_fashioned_recipe,
          @maple_old_fashioned_recipe,
          @margarita_recipe
        )

        expect(result).not_to include(
          private_recipe
        )
      end

      it "filters by drink name and visibility" do
        private_recipe =
          create(
            :recipe,
            drink:
              @whiskey_drink,
            name:
              "Private Whiskey Recipe",
            publicly_visible:
              false
          )

        result =
          Recipe.search_and_filter(
            drink_name:
              "old fashioned"
          )

        expect(
          result
        ).to contain_exactly(
          @old_fashioned_recipe,
          @maple_old_fashioned_recipe
        )

        expect(result).not_to include(
          private_recipe,
          @margarita_recipe
        )
      end

      it "filters recipes by drink id" do
        result =
          Recipe.search_and_filter(
            drink_id:
              @whiskey_drink.id
          )

        expect(
          result
        ).to contain_exactly(
          @old_fashioned_recipe,
          @maple_old_fashioned_recipe
        )

        expect(result).not_to include(
          @margarita_recipe
        )
      end
    end

    describe ".sorted_by" do
      describe "happy path" do
        it "sorts recipes by most recent first" do
          @old_fashioned_recipe
            .update!(
              created_at:
                3.days.ago
            )

          @maple_old_fashioned_recipe
            .update!(
              created_at:
                2.days.ago
            )

          @margarita_recipe
            .update!(
              created_at:
                1.day.ago
            )

          result =
            Recipe.sorted_by(
              "recent"
            )

          expect(
            result.first
          ).to eq(
            @margarita_recipe
          )

          expect(
            result.last
          ).to eq(
            @old_fashioned_recipe
          )
        end

        it "sorts recipes by most saved first" do
          user_two = create(
            :user,
            username: "bob",
            email: "bob@example.com"
          )

          user_three = create(
            :user,
            username: "charlie",
            email:
              "charlie@example.com"
          )

          UserRecipe.create!(
            user: user_two,
            recipe:
              @margarita_recipe
          )

          UserRecipe.create!(
            user: user_three,
            recipe:
              @margarita_recipe
          )

          UserRecipe.create!(
            user: user_two,
            recipe:
              @old_fashioned_recipe
          )

          result =
            Recipe.sorted_by(
              "saved"
            )

          expect(
            result.first
          ).to eq(
            @margarita_recipe
          )

          expect(
            result.second
          ).to eq(
            @old_fashioned_recipe
          )

          expect(
            result.last
          ).to eq(
            @maple_old_fashioned_recipe
          )
        end
      end

      describe "sad path" do
        it "returns all recipes when the sort option is not recognized" do
          result =
            Recipe.sorted_by(
              "not-a-real-sort"
            )

          expect(
            result
          ).to contain_exactly(
            @old_fashioned_recipe,
            @maple_old_fashioned_recipe,
            @margarita_recipe
          )
        end
      end
    end
  end

  describe "visibility" do
    before(:each) do
      @drink = create_drink(
        @user,
        {
          name:
            "Visibility Drink",
          alcoholic: true
        },
        category_names: [
          "Whiskey"
        ]
      )
    end

    describe "happy path" do
      it "is publicly visible by default" do
        recipe = create(
          :recipe,
          drink: @drink,
          name:
            "Public Recipe"
        )

        expect(
          recipe.publicly_visible
        ).to be(true)
      end

      it "returns only publicly visible recipes" do
        public_recipe = create(
          :recipe,
          drink: @drink,
          name:
            "Visible Recipe",
          publicly_visible: true
        )

        private_recipe = create(
          :recipe,
          drink: @drink,
          name:
            "Private Recipe",
          publicly_visible: false
        )

        result =
          Recipe.publicly_visible

        expect(result).to include(
          public_recipe
        )

        expect(result).not_to include(
          private_recipe
        )
      end
    end
  end
end
