require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = User.new(
        name: "John Doe", 
        username: "JohnDoe",
        email: "johndoe@example.com",
        password_digest: "johndoe@example.com"
      )
      expect(user).to be_valid
    end
    it "requires a name" do
      user = User.new(
        name: nil,
        username: "jonathan",
        email: "jonathan@example.com",
        password_digest: "password"
      )

      expect(user).to_not be_valid
      expect(user.errors.full_messages).to include("Name can't be blank")
    end

    it "requires a username" do
      user = User.new(
        name: "Jonathan",
        username: nil,
        email: "jonathan@example.com",
        password_digest: "password"
      )

      expect(user).to_not be_valid
      expect(user.errors.full_messages).to include("Username can't be blank")
    end

    it "requires a unique username" do
      User.create!(
        name: "Jonathan",
        username: "jonathan",
        email: "jonathan@example.com",
        password_digest: "password"
      )

      duplicate = User.new(
        name: "Another Jonathan",
        username: "jonathan",
        email: "other@example.com",
        password_digest: "password"
      )

      expect(duplicate).to_not be_valid
      expect(duplicate.errors.full_messages).to include("Username has already been taken")
    end

    it "requires an email" do
      user = User.new(
        name: "Jonathan",
        username: "jonathan",
        email: nil,
        password_digest: "password"
      )

      expect(user).to_not be_valid
      expect(user.errors.full_messages).to include("Email can't be blank")
    end

    it "requires a valid email format" do
      user = User.new(
        name: "Jonathan",
        username: "jonathan",
        email: "not-an-email",
        password_digest: "password"
      )

      expect(user).to_not be_valid
      expect(user.errors.full_messages).to include("Email is invalid")
    end

    it "requires a unique email" do
      User.create!(
        name: "Jonathan",
        username: "jonathan",
        email: "jonathan@example.com",
        password_digest: "password"
      )

      duplicate = User.new(
        name: "Other User",
        username: "otheruser",
        email: "jonathan@example.com",
        password_digest: "password"
      )

      expect(duplicate).to_not be_valid
      expect(duplicate.errors.full_messages).to include("Email has already been taken")
    end
  end
end
