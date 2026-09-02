FactoryBot.define do
  factory :category do
    sequence(:name) do |number|
      "Category #{number}"
    end

    alcoholic { true }

    association :ingredient,
                factory: :ingredient

    trait :nonalcoholic do
      alcoholic { false }
    end
  end
end
