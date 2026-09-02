FactoryBot.define do
  factory :drink_category do
    association :drink
    association :category
  end
end
