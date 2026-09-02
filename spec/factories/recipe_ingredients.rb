FactoryBot.define do
  factory :recipe_ingredient do
    association :recipe
    association :ingredient

    amount { 1.0 }
    measurement_unit { "oz" }
  end
end
