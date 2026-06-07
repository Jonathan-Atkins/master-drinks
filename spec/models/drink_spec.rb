require "rails_helper"

RSpec.describe Drink, type: :model do
  describe "validations" do
    describe "valid attributes" do
      it "is valid with a name" do
        drink = Drink.new(name: "Mojito", category: "Rum", alcoholic: true)
        expect(drink).to be_valid
      end
    end

    describe "invalid attributes" do
      it "is invalid without a name" do
        drink = Drink.new(name: nil, alcoholic: true)
        expect(drink).not_to be_valid
      end

      it "is invalid with a duplicate name" do
        Drink.create!(name: "Mojito", category: "Rum", alcoholic: true)
        drink = Drink.new(name: "Mojito", category: "Rum", alcoholic: true)
        expect(drink).not_to be_valid
        expect(drink.errors[:name]).to include("has already been taken")
      end

      it "is invalid without a category" do
        drink = Drink.new(name: "Mojito", category: nil, alcoholic: true)
        expect(drink).not_to be_valid
      end

      it "is invalid without alcoholic status" do
        drink = Drink.new(name: "Mojito", category: "Rum", alcoholic: nil)
        expect(drink).not_to be_valid
      end
    end
  end
end