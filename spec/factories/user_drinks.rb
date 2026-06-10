FactoryBot.define do
  factory :user_drink do
    user { nil }
    drink { nil }
    favorite { false }
    notes { "MyText" }
  end
end
