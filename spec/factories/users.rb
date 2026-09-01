FactoryBot.define do
  factory :user do
    name { "MyString" }
    email { "MyString" }
    password_digest { "MyString" }
    trait :seeded do
      seeded_account { true }
    end
  end
end
