module DrinkHelpers
  def create_category(
    name,
    alcoholic: nil
  )
    resolved_alcoholic =
      if alcoholic.nil?
        !name.start_with?(
          "Nonalcoholic"
        )
      else
        alcoholic
      end

    ingredient =
      Ingredient.find_by(
        "LOWER(name) = ?",
        name.downcase
      )

    unless ingredient
      ingredient =
        Ingredient.create!(
          name: name,
          user: nil,
          ingredient_type:
            "Spirit",
          flavor_profiles: []
        )
    end

    category =
      Category.find_or_initialize_by(
        name: name
      )

    if category.new_record?
      category.alcoholic =
        resolved_alcoholic

      category.ingredient =
        ingredient
    elsif category.ingredient.nil?
      category.ingredient =
        ingredient
    end

    category.save! if
      category.new_record? ||
      category.changed?

    category
  end

  def create_drink(
    user,
    attributes = {},
    category_names: nil
  )
    drink_attributes = {
      name: "Mojito",
      alcoholic: true,
      publicly_visible: true
    }.merge(attributes)

    resolved_category_names =
      if category_names.present?
        category_names
      elsif drink_attributes[
        :alcoholic
      ]
        [ "Rum" ]
      else
        [
          "Nonalcoholic Spirit"
        ]
      end

    categories =
      resolved_category_names.map do |name|
        create_category(name)
      end

    drink =
      user.drinks.new(
        drink_attributes
      )

    drink.categories =
      categories

    drink.save!

    drink
  end
end

RSpec.configure do |config|
  config.include DrinkHelpers
end
