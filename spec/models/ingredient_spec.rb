require "rails_helper"

RSpec.describe Ingredient, type: :model do
  let(:user) do
    create(
      :user,
      username: "ingredient_tester",
      email: "ingredient@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  describe "relationships" do
    context "happy path" do
      it "belongs to a user" do
        ingredient = create(
          :ingredient,
          user: user
        )

        expect(ingredient.user)
          .to eq(user)
      end

      it "has many recipe_ingredients" do
        ingredient = create(
          :ingredient,
          user: user
        )

        drink = create(
          :drink,
          user: user
        )

        recipe = create(
          :recipe,
          drink: drink
        )

        recipe_ingredient = create(
          :recipe_ingredient,
          ingredient: ingredient,
          recipe: recipe
        )

        expect(
          ingredient.recipe_ingredients
        ).to include(recipe_ingredient)
      end

      it "has many recipes through recipe_ingredients" do
        ingredient = create(
          :ingredient,
          user: user
        )

        drink = create(
          :drink,
          user: user
        )

        recipe = create(
          :recipe,
          drink: drink
        )

        create(
          :recipe_ingredient,
          ingredient: ingredient,
          recipe: recipe
        )

        expect(
          ingredient.recipes
        ).to include(recipe)
      end
    end
  end

  describe "validations" do
    context "happy path" do
      it "is valid with valid attributes" do
        ingredient = build(
          :ingredient,
          user: user,
          ingredient_type: "Spirit",
          flavor_profiles: [
            "Sweet",
            "Rich"
          ]
        )

        expect(ingredient)
          .to be_valid
      end

      it "allows an approved ingredient type" do
        ingredient = build(
          :ingredient,
          user: user,
          ingredient_type: "Spirit"
        )

        expect(ingredient)
          .to be_valid
      end

      it "allows approved flavor profiles" do
        ingredient = build(
          :ingredient,
          user: user,
          flavor_profiles: [
            "Sweet",
            "Tropical",
            "Fruity"
          ]
        )

        expect(ingredient)
          .to be_valid
      end

      it "allows an empty flavor profile array" do
        ingredient = build(
          :ingredient,
          user: user,
          flavor_profiles: []
        )

        expect(ingredient)
          .to be_valid
      end
    end

    context "sad path" do
      it "requires a name" do
        ingredient = build(
          :ingredient,
          user: user,
          name: nil
        )

        expect(ingredient)
          .not_to be_valid

        expect(
          ingredient.errors[:name]
        ).to be_present
      end

      it "does not allow duplicate names" do
        create(
          :ingredient,
          user: user,
          name: "Lime Juice"
        )

        duplicate = build(
          :ingredient,
          user: user,
          name: "Lime Juice"
        )

        expect(duplicate)
          .not_to be_valid

        expect(
          duplicate.errors[:name]
        ).to be_present
      end

      it "does not allow case-insensitive duplicate names" do
        create(
          :ingredient,
          user: user,
          name: "Lime Juice"
        )

        duplicate = build(
          :ingredient,
          user: user,
          name: "lime juice"
        )

        expect(duplicate)
          .not_to be_valid

        expect(
          duplicate.errors[:name]
        ).to be_present
      end

      it "does not allow an unsupported ingredient type" do
        ingredient = build(
          :ingredient,
          user: user,
          ingredient_type: "Unknown"
        )

        expect(ingredient)
          .not_to be_valid

        expect(
          ingredient.errors[:ingredient_type]
        ).to be_present
      end

      it "does not allow an unsupported flavor profile" do
        ingredient = build(
          :ingredient,
          user: user,
          flavor_profiles: [
            "Sweet",
            "Unknown"
          ]
        )

        expect(ingredient)
          .not_to be_valid

        expect(
          ingredient.errors[:flavor_profiles]
        ).to be_present
      end
    end
  end

  describe "ingredient options" do
    context "happy path" do
      it "defines the supported ingredient types" do
        expect(
          Ingredient::INGREDIENT_TYPES
        ).to eq(
          [
            "Spirit",
            "Liqueur",
            "Wine",
            "Beer",
            "Bitters",
            "Syrup",
            "Citrus",
            "Juice",
            "Mixer",
            "Dairy",
            "Sweetener",
            "Herb",
            "Spice",
            "Garnish",
            "Other"
          ]
        )
      end

      it "defines the supported flavor profiles" do
        expect(
          Ingredient::FLAVOR_PROFILES
        ).to eq(
          [
            "Sweet",
            "Sour",
            "Bitter",
            "Herbal",
            "Floral",
            "Tropical",
            "Spicy",
            "Smoky",
            "Fruity",
            "Creamy",
            "Savory",
            "Citrusy",
            "Dry",
            "Rich"
          ]
        )
      end
    end
  end
end