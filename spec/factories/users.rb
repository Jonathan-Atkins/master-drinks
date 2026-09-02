FactoryBot.define do
  factory :user do
    sequence(:name) do |number|
      "User #{number}"
    end

    sequence(:username) do |number|
      "user#{number}"
    end

    sequence(:email) do |number|
      "user#{number}@example.com"
    end

    password { "password123" }
    password_confirmation { "password123" }

    trait :seeded do
      seeded_account { true }
    end
  end
end
