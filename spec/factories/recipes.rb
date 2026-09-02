FactoryBot.define do
  factory :recipe do
    association :drink

    sequence(:name) do |number|
      "Recipe #{number}"
    end

    instructions {
      "Combine ingredients and serve."
    }

    publicly_visible { true }
  end
end
