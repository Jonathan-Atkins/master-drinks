require "rails_helper"

RSpec.describe Drink, type: :model do
  describe "validations" do
    describe "valid attributes" do
      it "is valid with a name" do
        drink = Drink.new(name: "Mojito", alcoholic: true)

        expect(drink).to be_valid
      end
    end

    describe "invalid attributes" do
      it "is invalid without a name" do
        drink = Drink.new(name: nil, alcoholic: true)

        expect(drink).not_to be_valid
      end
    end
  end
end