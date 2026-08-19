FactoryBot.define do
  factory :drink do
    name { "MyString" }
    alcoholic { false }

    transient do
      category_names { [ "Rum" ] }
    end

    after(:build) do |drink, evaluator|
      categories = evaluator.category_names.map do |name|
        Category.find_or_create_by!(name: name)
      end

      drink.categories = categories
    end
  end
end
