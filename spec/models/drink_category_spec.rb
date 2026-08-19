require "rails_helper"

RSpec.describe DrinkCategory, type: :model do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "AliceInWonderLand",
      email: "alice@email.com",
      password: "12345",
      password_confirmation: "12345"
    )

    @category = Category.create!(
      name: "Rum"
    )

    @drink = @user.drinks.new(
      name: "Mojito",
      alcoholic: true
    )

    @drink.categories = [ @category ]
    @drink.save!
  end

  describe "relationships" do
    describe "happy path" do
      it "belongs to a drink" do
        drink_category = DrinkCategory.find_by!(
          drink: @drink,
          category: @category
        )

        expect(drink_category.drink).to eq(@drink)
      end

      it "belongs to a category" do
        drink_category = DrinkCategory.find_by!(
          drink: @drink,
          category: @category
        )

        expect(drink_category.category).to eq(@category)
      end

      it "connects a drink to a category" do
        drink_category = DrinkCategory.find_by!(
          drink: @drink,
          category: @category
        )

        expect(drink_category.drink).to eq(@drink)
        expect(drink_category.category).to eq(@category)
      end
    end

    describe "sad path" do
      it "is invalid without a drink" do
        drink_category = DrinkCategory.new(
          category: @category
        )

        expect(drink_category).not_to be_valid
        expect(drink_category.errors[:drink]).to include("must exist")
      end

      it "is invalid without a category" do
        drink_category = DrinkCategory.new(
          drink: @drink
        )

        expect(drink_category).not_to be_valid
        expect(drink_category.errors[:category]).to include("must exist")
      end
    end
  end
end
