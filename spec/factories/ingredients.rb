FactoryBot.define do
  factory :ingredient do
    sequence(:name) do |number|
      "Ingredient #{number}"
    end

    ingredient_type { "Spirit" }

    flavor_profiles { [] }

    user { nil }
  end
end
