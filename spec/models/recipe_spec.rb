require "rails_helper"

RSpec.describe Recipe, type: :model do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "AliceInWonderLand",
      email: "alice@email.com",
      password: "12345",
      password_confirmation: "12345",
    )
  end

  describe "relationships" do
    it "belongs to a drink" do
      drink = create_drink(
        @user,
        { name: "Old Fashioned", alcoholic: true },
        category_names: [ "Whiskey" ]
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir ingredients with ice and strain over a large cube.",
      )

      expect(recipe.drink).to eq(drink)
    end

    it "has many ingredients through recipe_ingredients" do
      drink = create_drink(
        @user,
        { name: "Old Fashioned", alcoholic: true },
        category_names: [ "Whiskey" ]
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir ingredients with ice and strain over a large cube.",
      )

      bourbon = Ingredient.create!(
        name: "Bourbon",
        user: @user,
      )

      bitters = Ingredient.create!(
        name: "Bitters",
        user: @user,
      )

      RecipeIngredient.create!(
        recipe: recipe,
        ingredient: bourbon,
        amount: 2,
        measurement_unit: "oz",
      )

      RecipeIngredient.create!(
        recipe: recipe,
        ingredient: bitters,
        amount: 2,
        measurement_unit: "dashes",
      )

      expect(recipe.ingredients).to contain_exactly(
        bourbon,
        bitters
      )
    end

    it "destroys user_recipes when the recipe is destroyed" do
      other_user = User.create!(
        name: "Bob",
        username: "bob",
        email: "bob@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      drink = create_drink(
        @user,
        {
          name: "Margarita",
          alcoholic: true
        },
        category_names: [ "Tequila" ]
      )

      recipe = Recipe.create!(
        drink: drink,
        name: "Classic Margarita",
        instructions: "Shake with ice."
      )

      user_recipe = UserRecipe.create!(
        user: other_user,
        recipe: recipe
      )

      recipe.destroy

      expect(
        UserRecipe.exists?(user_recipe.id)
      ).to be(false)

      expect(
        User.exists?(other_user.id)
      ).to be(true)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      drink = create_drink(
        @user,
        { name: "Old Fashioned", alcoholic: true },
        category_names: [ "Whiskey" ]
      )

      recipe = Recipe.new(
        drink: drink,
        name: "Classic Old Fashioned",
        instructions: "Stir ingredients with ice and strain over a large cube.",
      )

      expect(recipe).to be_valid
    end

    it "requires a name" do
      drink = create_drink(
        @user,
        { name: "Old Fashioned", alcoholic: true },
        category_names: [ "Whiskey" ]
      )

      recipe = Recipe.new(
        drink: drink,
        name: nil,
        instructions: "Stir ingredients with ice and strain over a large cube.",
      )

      expect(recipe).not_to be_valid

      expect(
        recipe.errors.full_messages
      ).to include("Name can't be blank")
    end

    it "requires a drink" do
      recipe = Recipe.new(
        drink: nil,
        name: "Classic Old Fashioned",
        instructions: "Stir ingredients with ice and strain over a large cube.",
      )

      expect(recipe).not_to be_valid

      expect(
        recipe.errors.full_messages
      ).to include("Drink must exist")
    end
  end

  describe "class methods" do
    before(:each) do
      @whiskey_drink = create_drink(
        @user,
        { name: "Old Fashioned", alcoholic: true },
        category_names: [ "Whiskey" ]
      )

      @tequila_drink = create_drink(
        @user,
        { name: "Margarita", alcoholic: true },
        category_names: [ "Tequila" ]
      )

      @old_fashioned_recipe = Recipe.create!(
        drink: @whiskey_drink,
        name: "Classic Old Fashioned",
        instructions: "Stir ingredients with ice and strain over a large cube.",
      )

      @maple_old_fashioned_recipe = Recipe.create!(
        drink: @whiskey_drink,
        name: "Maple Old Fashioned",
        instructions: "Stir ingredients with maple syrup and ice.",
      )

      @margarita_recipe = Recipe.create!(
        drink: @tequila_drink,
        name: "Classic Margarita",
        instructions: "Shake with ice and strain into a glass.",
      )
    end

    describe ".by_drink_id" do
      it "returns recipes associated with a specific drink id" do
        result =
          Recipe.by_drink_id(
            @whiskey_drink.id
          )

        expect(result).to contain_exactly(
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

        expect(result).to contain_exactly(
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

        expect(result).to contain_exactly(
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
            drink_name: "old fashioned"
          )

        expect(result).to contain_exactly(
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

        expect(result).to contain_exactly(
          @old_fashioned_recipe,
          @maple_old_fashioned_recipe,
          @margarita_recipe
        )
      end
    end

    describe ".search_and_filter" do
      it "returns only publicly visible recipes" do
        private_recipe = Recipe.create!(
          drink: @whiskey_drink,
          name: "Private Old Fashioned",
          instructions: "Private instructions.",
          publicly_visible: false
        )

        result =
          Recipe.search_and_filter({})

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
        private_recipe = Recipe.create!(
          drink: @whiskey_drink,
          name: "Private Whiskey Recipe",
          instructions: "Private instructions.",
          publicly_visible: false
        )

        result =
          Recipe.search_and_filter(
            drink_name: "old fashioned"
          )

        expect(result).to contain_exactly(
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
            drink_id: @whiskey_drink.id
          )

        expect(result).to contain_exactly(
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
          @old_fashioned_recipe.update!(
            created_at: 3.days.ago
          )

          @maple_old_fashioned_recipe.update!(
            created_at: 2.days.ago
          )

          @margarita_recipe.update!(
            created_at: 1.day.ago
          )

          result =
            Recipe.sorted_by("recent")

          expect(result.first).to eq(
            @margarita_recipe
          )

          expect(result.last).to eq(
            @old_fashioned_recipe
          )
        end

        it "sorts recipes by most saved first" do
          user_two = User.create!(
            name: "Bob",
            username: "bob",
            email: "bob@example.com",
            password: "password123",
            password_confirmation: "password123"
          )

          user_three = User.create!(
            name: "Charlie",
            username: "charlie",
            email: "charlie@example.com",
            password: "password123",
            password_confirmation: "password123"
          )

          UserRecipe.create!(
            user: user_two,
            recipe: @margarita_recipe
          )

          UserRecipe.create!(
            user: user_three,
            recipe: @margarita_recipe
          )

          UserRecipe.create!(
            user: user_two,
            recipe: @old_fashioned_recipe
          )

          result =
            Recipe.sorted_by("saved")

          expect(result.first).to eq(
            @margarita_recipe
          )

          expect(result.second).to eq(
            @old_fashioned_recipe
          )

          expect(result.last).to eq(
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

          expect(result).to contain_exactly(
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
        { name: "Old Fashioned", alcoholic: true },
        category_names: [ "Whiskey" ]
      )
    end

    it "is publicly visible by default" do
      recipe = Recipe.create!(
        drink: @drink,
        name: "Classic Old Fashioned",
        instructions: "Stir ingredients with ice.",
      )

      expect(
        recipe.publicly_visible
      ).to be(true)
    end

    it "returns only publicly visible recipes" do
      public_recipe = Recipe.create!(
        drink: @drink,
        name: "Public Old Fashioned",
        instructions: "Stir ingredients with ice.",
        publicly_visible: true,
      )

      private_recipe = Recipe.create!(
        drink: @drink,
        name: "Private Old Fashioned",
        instructions: "Stir ingredients with ice.",
        publicly_visible: false,
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