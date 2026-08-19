require "rails_helper"

RSpec.describe Category, type: :model do
  describe "validations" do
    describe "happy path" do
      it "is valid with a name" do
        category = Category.new(name: "Whiskey")

        expect(category).to be_valid
      end

      it "automatically generates a slug from the name" do
        category = Category.create!(name: "Irish Whiskey")

        expect(category.slug).to eq("irish-whiskey")
      end
    end

    describe "sad path" do
      it "is invalid without a name" do
        category = Category.new(name: nil)

        expect(category).not_to be_valid
        expect(category.errors[:name]).to include("can't be blank")
      end

      it "does not allow duplicate names" do
        Category.create!(name: "Vodka")

        duplicate = Category.new(name: "Vodka")

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include("has already been taken")
      end

      it "does not allow duplicate slugs" do
        Category.create!(name: "Irish Whiskey")

        duplicate = Category.new(name: "Irish-Whiskey")

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:slug]).to include("has already been taken")
      end
    end
  end

  describe "slug generation" do
    describe "happy path" do
      it "converts spaces to hyphens" do
        category = Category.create!(name: "White Rum")

        expect(category.slug).to eq("white-rum")
      end

      it "converts the slug to lowercase" do
        category = Category.create!(name: "Japanese Whisky")

        expect(category.slug).to eq("japanese-whisky")
      end
    end
  end

  describe "relationships" do
    describe "happy path" do
      it "has many drinks through drink categories" do
        user = User.create!(
          name: "Alice",
          username: "AliceInWonderLand",
          email: "alice@email.com",
          password: "12345",
          password_confirmation: "12345"
        )

        category = Category.create!(name: "Rum")

        drink = user.drinks.new(
          name: "Mojito",
          alcoholic: true
        )

        drink.categories << category
        drink.save!

        expect(category.drinks).to include(drink)
      end

      it "has many drink categories" do
        user = User.create!(
          name: "Alice",
          username: "AliceInWonderLand",
          email: "alice@email.com",
          password: "12345",
          password_confirmation: "12345"
        )

        category = Category.create!(name: "Tequila")

        drink = user.drinks.new(
          name: "Margarita",
          alcoholic: true
        )

        drink.categories << category
        drink.save!

        expect(category.drink_categories.count).to eq(1)
        expect(category.drink_categories.first.drink).to eq(drink)
      end

      it "destroys associated drink categories when deleted" do
        user = User.create!(
          name: "Alice",
          username: "AliceInWonderLand",
          email: "alice@email.com",
          password: "12345",
          password_confirmation: "12345"
        )

        category = Category.create!(name: "Gin")

        drink = user.drinks.new(
          name: "Martini",
          alcoholic: true
        )

        drink.categories << category
        drink.save!

        drink_category_id = category.drink_categories.first.id

        category.destroy

        expect(DrinkCategory.exists?(drink_category_id)).to be(false)
      end
    end
  end
end
