# require "rails_helper"

# RSpec.describe UserDrink, type: :model do
#   describe "relationships" do
#     it "connects a user to a drink" do
#       user = User.create!(
#         name: "Jonathan",
#         username: "jonathan",
#         email: "jonathan@example.com",
#         password_digest: "password"
#       )

#       drink = Drink.create!(
#         name: "Margarita",
#         category: "tequila",
#         alcoholic: true
#       )

#       user_drink = UserDrink.create!(user: user, drink: drink)

#       expect(user_drink.user).to eq(user)
#       expect(user_drink.drink).to eq(drink)
#     end
#   end

#   describe "validations" do
#     it "does not allow the same user to save the same drink twice" do
#       user = User.create!(
#         name: "Jonathan",
#         username: "jonathan",
#         email: "jonathan@example.com",
#         password_digest: "password"
#       )

#       drink = Drink.create!(
#         name: "Margarita",
#         category: "tequila",
#         alcoholic: true
#       )

#       UserDrink.create!(user: user, drink: drink)

#       duplicate = UserDrink.new(user: user, drink: drink)

#       expect(duplicate).to_not be_valid
#       expect(duplicate.errors.full_messages).to include("Drink has already been taken")
#     end
#   end
# end