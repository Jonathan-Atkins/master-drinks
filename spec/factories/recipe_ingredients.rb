FactoryBot.define do
  factory :recipe_ingredient do
    recipe { nil }
    ingredient { nil }
    amount { "9.99" }
    measurement_unit { "MyString" }
  end
end
