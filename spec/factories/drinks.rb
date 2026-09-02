FactoryBot.define do
  factory :drink do
    association :user

    sequence(:name) do |number|
      "Drink #{number}"
    end

    alcoholic { true }

    publicly_visible { true }

    transient do
      category_names { nil }
    end

    after(:build) do |drink, evaluator|
      names =
        if evaluator.category_names.present?
          evaluator.category_names
        elsif drink.alcoholic?
          [ "Rum" ]
        else
          [ "Nonalcoholic Spirit" ]
        end

      categories =
        names.map do |category_name|
          existing_category =
            Category.find_by(
              name: category_name
            )

          next existing_category if existing_category

          ingredient =
            Ingredient.find_by(
              "LOWER(name) = ?",
              category_name.downcase
            )

          ingredient ||=
            FactoryBot.create(
              :ingredient,
              name: category_name,
              user: nil
            )

          category_alcoholic =
            !category_name.start_with?(
              "Nonalcoholic"
            )

          FactoryBot.create(
            :category,
            name: category_name,
            alcoholic:
              category_alcoholic,
            ingredient: ingredient
          )
        end

      drink.categories =
        categories
    end
  end
end
