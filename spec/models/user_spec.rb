require "rails_helper"

RSpec.describe User, type: :model do
  before(:each) do
    @valid_attributes = {
      name: "John Doe",
      username: "JohnDoe",
      email: "johndoe@example.com",
      password: "password123",
      password_confirmation: "password123"
    }

    @user = User.create!(
      name: "Alice",
      username: "alice",
      email: "alice@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      user = User.new(@valid_attributes)

      expect(user).to be_valid
    end

    it "requires a name" do
      user = User.new(@valid_attributes.merge(name: nil))

      expect(user).not_to be_valid
      expect(user.errors.full_messages).to include("Name can't be blank")
    end

    it "requires a username" do
      user = User.new(@valid_attributes.merge(username: nil))

      expect(user).not_to be_valid
      expect(user.errors.full_messages).to include("Username can't be blank")
    end

    it "requires a unique username" do
      User.create!(@valid_attributes)

      duplicate = User.new(
        @valid_attributes.merge(
          name: "Another User",
          email: "other@example.com"
        )
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors.full_messages).to include(
        "Username has already been taken"
      )
    end

    it "requires an email" do
      user = User.new(@valid_attributes.merge(email: nil))

      expect(user).not_to be_valid
      expect(user.errors.full_messages).to include("Email can't be blank")
    end

    it "requires a valid email format" do
      user = User.new(@valid_attributes.merge(email: "not-an-email"))

      expect(user).not_to be_valid
      expect(user.errors.full_messages).to include("Email is invalid")
    end

    it "requires a unique email" do
      User.create!(@valid_attributes)

      duplicate = User.new(
        @valid_attributes.merge(
          name: "Other User",
          username: "otheruser"
        )
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors.full_messages).to include(
        "Email has already been taken"
      )
    end

    it "authenticates with the correct password" do
      user = User.create!(
        name: "Jonathan",
        username: "jonathan",
        email: "jonathan@example.com",
        password: "password123",
        password_confirmation: "password123"
      )

      expect(user.authenticate("password123")).to eq(user)
      expect(user.authenticate("wrong-password")).to eq(false)
    end
  end

  describe "relationships" do
    it "can have many drinks" do
      user = User.create!(@valid_attributes)

      margarita = user.drinks.create!(
        name: "Margarita",
        category: "tequila",
        alcoholic: true
      )

      expect(user.drinks).to include(margarita)
    end

    it "can have many recipes through user_recipes" do
      user = User.create!(@valid_attributes)

      margarita = user.drinks.create!(
        name: "Margarita",
        category: "tequila",
        alcoholic: true
      )

      classic_recipe = Recipe.create!(
        drink: margarita,
        name: "Classic Margarita",
        instructions: "Shake with ice and strain."
      )

      spicy_recipe = Recipe.create!(
        drink: margarita,
        name: "Spicy Margarita",
        instructions: "Shake with jalapeño, ice, and strain."
      )

      UserRecipe.create!(
        user: user,
        recipe: classic_recipe
      )

      UserRecipe.create!(
        user: user,
        recipe: spicy_recipe
      )

      expect(user.recipes).to contain_exactly(
        classic_recipe,
        spicy_recipe
      )
    end
  end
end
