module DrinkHelpers
  def create_category(name)
    Category.find_or_create_by!(name: name)
  end

  def create_drink(user, attributes = {}, category_names: [ "Rum" ])
    categories = category_names.map { |name| create_category(name) }

    drink = user.drinks.new(
      {
        name: "Mojito",
        alcoholic: true
      }.merge(attributes)
    )

    drink.categories = categories
    drink.save!
    drink
  end
end

RSpec.configure do |config|
  config.include DrinkHelpers
end
