require "rails_helper"

RSpec.describe Category, type: :model do
  describe "validations" do
    describe "happy path" do
      it "is valid with a global ingredient and alcoholic status" do
        ingredient = create(
          :ingredient,
          name: "Spec Spirit"
        )

        category = build(
          :category,
          name: "Spec Spirit",
          ingredient: ingredient,
          alcoholic: true
        )

        expect(category).to be_valid
      end

      it "automatically generates a slug from the name" do
        category = create(
          :category,
          name: "Spec Irish Spirit"
        )

        expect(category.slug).to eq(
          "spec-irish-spirit"
        )
      end

      it "allows an alcoholic category" do
        category = build(
          :category,
          name: "Spec Bourbon",
          alcoholic: true
        )

        expect(category).to be_valid
      end

      it "allows a nonalcoholic category" do
        category = build(
          :category,
          :nonalcoholic,
          name: "Spec Nonalcoholic Spirit"
        )

        expect(category).to be_valid
      end
    end

    describe "sad path" do
      it "is invalid without a name" do
        category = build(
          :category,
          name: nil
        )

        expect(category).not_to be_valid

        expect(
          category.errors[:name]
        ).to include(
          "can't be blank"
        )
      end

      it "does not allow duplicate names" do
        create(
          :category,
          name: "Spec Duplicate Spirit"
        )

        duplicate = build(
          :category,
          name: "Spec Duplicate Spirit"
        )

        expect(duplicate).not_to be_valid

        expect(
          duplicate.errors[:name]
        ).to include(
          "has already been taken"
        )
      end

      it "does not allow duplicate slugs" do
        create(
          :category,
          name: "Spec Test Spirit"
        )

        duplicate = build(
          :category,
          name: "Spec-Test-Spirit"
        )

        expect(duplicate).not_to be_valid

        expect(
          duplicate.errors[:slug]
        ).to include(
          "has already been taken"
        )
      end

      it "is invalid without an ingredient" do
        category = build(
          :category,
          ingredient: nil
        )

        expect(category).not_to be_valid

        expect(
          category.errors[:ingredient]
        ).to include(
          "must exist"
        )
      end

      it "does not allow a user-owned ingredient" do
        user = create(:user)

        ingredient = create(
          :ingredient,
          user: user
        )

        category = build(
          :category,
          ingredient: ingredient
        )

        expect(category).not_to be_valid

        expect(
          category.errors[:ingredient]
        ).to include(
          "must be a global ingredient"
        )
      end

      it "is invalid without alcoholic status" do
        category = build(
          :category,
          alcoholic: nil
        )

        expect(category).not_to be_valid

        expect(
          category.errors[:alcoholic]
        ).to include(
          "is not included in the list"
        )
      end
    end
  end

  describe "slug generation" do
    describe "happy path" do
      it "converts spaces to hyphens" do
        category = create(
          :category,
          name: "Spec White Spirit"
        )

        expect(category.slug).to eq(
          "spec-white-spirit"
        )
      end

      it "converts the slug to lowercase" do
        category = create(
          :category,
          name: "Spec Japanese Spirit"
        )

        expect(category.slug).to eq(
          "spec-japanese-spirit"
        )
      end
    end
  end

  describe "scopes" do
    describe "happy path" do
      it "returns alcoholic categories" do
        alcoholic_category = create(
          :category,
          name: "Spec Gin",
          alcoholic: true
        )

        nonalcoholic_category = create(
          :category,
          :nonalcoholic,
          name: "Spec Nonalcoholic Gin"
        )

        result = Category.alcoholic

        expect(result).to include(
          alcoholic_category
        )

        expect(result).not_to include(
          nonalcoholic_category
        )
      end

      it "returns nonalcoholic categories" do
        alcoholic_category = create(
          :category,
          name: "Spec Rum",
          alcoholic: true
        )

        nonalcoholic_category = create(
          :category,
          :nonalcoholic,
          name: "Spec Nonalcoholic Rum"
        )

        result = Category.nonalcoholic

        expect(result).to include(
          nonalcoholic_category
        )

        expect(result).not_to include(
          alcoholic_category
        )
      end
    end
  end

  describe "relationships" do
    describe "happy path" do
      it "belongs to an ingredient" do
        ingredient = create(
          :ingredient,
          name: "Spec Tequila"
        )

        category = create(
          :category,
          name: "Spec Tequila",
          ingredient: ingredient
        )

        expect(
          category.ingredient
        ).to eq(ingredient)
      end

      it "has many drinks through drink categories" do
        user = create(:user)

        category = create(
          :category,
          name: "Spec Rum",
          alcoholic: true
        )

        drink = user.drinks.new(
          name: "Spec Mojito",
          alcoholic: true
        )

        drink.categories = [
          category
        ]

        drink.save!

        expect(
          category.drinks
        ).to include(drink)
      end

      it "has many drink categories" do
        user = create(:user)

        category = create(
          :category,
          name: "Spec Tequila",
          alcoholic: true
        )

        drink = user.drinks.new(
          name: "Spec Margarita",
          alcoholic: true
        )

        drink.categories = [
          category
        ]

        drink.save!

        expect(
          category.drink_categories.count
        ).to eq(1)

        expect(
          category
            .drink_categories
            .first
            .drink
        ).to eq(drink)
      end

      it "destroys associated drink categories when deleted" do
        user = create(:user)

        category = create(
          :category,
          name: "Spec Gin",
          alcoholic: true
        )

        drink = user.drinks.new(
          name: "Spec Martini",
          alcoholic: true
        )

        drink.categories = [
          category
        ]

        drink.save!

        drink_category_id =
          category
            .drink_categories
            .first
            .id

        category.destroy

        expect(
          DrinkCategory.exists?(
            drink_category_id
          )
        ).to be(false)
      end
    end
  end
end
