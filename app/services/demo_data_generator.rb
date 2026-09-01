require "securerandom"

class DemoDataGenerator
  USER_COUNT = 50

  FIRST_NAMES = %w[
    Maya Andre Sofia Jordan Marcus Elena
    Cameron Nina Mateo Jasmine Tyler Chloe
    Diego Olivia Julian Naomi Xavier Leah
    Adrian Vanessa Miles Gabriela Ethan
    Bianca Lucas Camille Dominic Isabella
    Noah Serena Rafael Alexis Dante Kiara
    Roman Natalie Victor Amara Gabriel
    Zoe Isaiah Daniela Leo Simone Malik
    Talia Marco Alana
  ].freeze

  LAST_NAMES = %w[
    Thompson Collins Ramirez Brooks Carter
    Rivera Bennett Foster Morales Reed
    Sullivan Hayes Ortiz Morgan Cruz
    Parker Nguyen Torres Price Flores
    Coleman Diaz Stewart Russell Jenkins
    Powell Long Patterson Hughes Washington
    Butler Simmons Griffin Bryant Alexander
    Sanders Ross Henderson Perry Woods
    Barnes Fisher West Chapman Stone
  ].freeze

  DRINK_CATALOG = [
    {
      name: "Margarita",
      alcoholic: true,
      category: "tequila"
    },
    {
      name: "Negroni",
      alcoholic: true,
      category: "gin"
    },
    {
      name: "Old Fashioned",
      alcoholic: true,
      category: "bourbon"
    },
    {
      name: "Daiquiri",
      alcoholic: true,
      category: "white-rum"
    },
    {
      name: "Mojito",
      alcoholic: true,
      category: "white-rum"
    },
    {
      name: "Manhattan",
      alcoholic: true,
      category: "rye"
    },
    {
      name: "Martini",
      alcoholic: true,
      category: "gin"
    },
    {
      name: "Moscow Mule",
      alcoholic: true,
      category: "vodka"
    },
    {
      name: "Paloma",
      alcoholic: true,
      category: "tequila"
    },
    {
      name: "Whiskey Sour",
      alcoholic: true,
      category: "whiskey"
    },
    {
      name: "Tom Collins",
      alcoholic: true,
      category: "gin"
    },
    {
      name: "French 75",
      alcoholic: true,
      category: "gin"
    },
    {
      name: "Gimlet",
      alcoholic: true,
      category: "gin"
    },
    {
      name: "Sidecar",
      alcoholic: true,
      category: "cognac"
    },
    {
      name: "Boulevardier",
      alcoholic: true,
      category: "bourbon"
    },
    {
      name: "Mai Tai",
      alcoholic: true,
      category: "rum"
    },
    {
      name: "Piña Colada",
      alcoholic: true,
      category: "rum"
    },
    {
      name: "Dark and Stormy",
      alcoholic: true,
      category: "dark-rum"
    },
    {
      name: "Espresso Martini",
      alcoholic: true,
      category: "vodka"
    },
    {
      name: "Cosmopolitan",
      alcoholic: true,
      category: "vodka"
    },
    {
      name: "Aperol Spritz",
      alcoholic: true,
      category: "aperitif"
    },
    {
      name: "Sazerac",
      alcoholic: true,
      category: "rye"
    },
    {
      name: "Mint Julep",
      alcoholic: true,
      category: "bourbon"
    },
    {
      name: "Penicillin",
      alcoholic: true,
      category: "scotch"
    },
    {
      name: "Mezcal Negroni",
      alcoholic: true,
      category: "mezcal"
    },
    {
      name: "Caipirinha",
      alcoholic: true,
      category: "cachaca"
    },
    {
      name: "Irish Coffee",
      alcoholic: true,
      category: "irish-whiskey"
    },
    {
      name: "Bee's Knees",
      alcoholic: true,
      category: "gin"
    },
    {
      name: "Virgin Mojito",
      alcoholic: false,
      category: "non-alcoholic"
    },
    {
      name: "Shirley Temple",
      alcoholic: false,
      category: "non-alcoholic"
    },
    {
      name: "Virgin Piña Colada",
      alcoholic: false,
      category: "non-alcoholic"
    },
    {
      name: "Roy Rogers",
      alcoholic: false,
      category: "non-alcoholic"
    },
    {
      name: "Cucumber Cooler",
      alcoholic: false,
      category: "non-alcoholic"
    },
    {
      name: "Ginger Lime Fizz",
      alcoholic: false,
      category: "non-alcoholic"
    },
    {
      name: "Pineapple Mint Cooler",
      alcoholic: false,
      category: "non-alcoholic"
    },
    {
      name: "Grapefruit Spritz",
      alcoholic: false,
      category: "non-alcoholic"
    }
  ].freeze

  RECIPE_CATALOG = {
    "Margarita" => {
      ingredients: [
        [ "Tequila Blanco", 2, "oz" ],
        [ "Triple Sec", 0.75, "oz" ],
        [ "Lime Juice", 0.75, "oz" ]
      ],
      instructions:
        "Shake with ice and strain into a chilled glass."
    },

    "Negroni" => {
      ingredients: [
        [ "Gin", 1, "oz" ],
        [ "Campari", 1, "oz" ],
        [ "Sweet Vermouth", 1, "oz" ]
      ],
      instructions:
        "Stir with ice and strain over fresh ice."
    },

    "Old Fashioned" => {
      ingredients: [
        [ "Bourbon", 2, "oz" ],
        [ "Simple Syrup", 0.25, "oz" ],
        [ "Angostura Bitters", 3, "dash" ]
      ],
      instructions:
        "Stir with ice and serve over a large cube."
    },

    "Daiquiri" => {
      ingredients: [
        [ "Light Rum", 2, "oz" ],
        [ "Lime Juice", 1, "oz" ],
        [ "Simple Syrup", 0.75, "oz" ]
      ],
      instructions:
        "Shake with ice and strain into a chilled coupe."
    },

    "Mojito" => {
      ingredients: [
        [ "Light Rum", 2, "oz" ],
        [ "Lime Juice", 0.75, "oz" ],
        [ "Simple Syrup", 0.5, "oz" ],
        [ "Mint", 8, "leaf" ],
        [ "Club Soda", 2, "oz" ]
      ],
      instructions:
        "Combine rum, lime juice, syrup, and mint with ice. Top with club soda."
    },

    "Manhattan" => {
      ingredients: [
        [ "Rye Whiskey", 2, "oz" ],
        [ "Sweet Vermouth", 1, "oz" ],
        [ "Angostura Bitters", 2, "dash" ]
      ],
      instructions:
        "Stir with ice and strain into a chilled cocktail glass."
    },

    "Martini" => {
      ingredients: [
        [ "Gin", 2.5, "oz" ],
        [ "Dry Vermouth", 0.5, "oz" ]
      ],
      instructions:
        "Stir with ice and strain into a chilled martini glass."
    },

    "Moscow Mule" => {
      ingredients: [
        [ "Vodka", 2, "oz" ],
        [ "Lime Juice", 0.5, "oz" ],
        [ "Ginger Beer", 4, "oz" ]
      ],
      instructions:
        "Build over ice and top with ginger beer."
    },

    "Paloma" => {
      ingredients: [
        [ "Tequila Blanco", 2, "oz" ],
        [ "Lime Juice", 0.5, "oz" ],
        [ "Grapefruit Soda", 3, "oz" ]
      ],
      instructions:
        "Build over ice and top with grapefruit soda."
    },

    "Whiskey Sour" => {
      ingredients: [
        [ "Bourbon", 2, "oz" ],
        [ "Lemon Juice", 0.75, "oz" ],
        [ "Simple Syrup", 0.75, "oz" ],
        [ "Egg White", 1, "each" ]
      ],
      instructions:
        "Dry shake, add ice, shake again, and strain."
    },

    "Tom Collins" => {
      ingredients: [
        [ "Gin", 2, "oz" ],
        [ "Lemon Juice", 1, "oz" ],
        [ "Simple Syrup", 0.5, "oz" ],
        [ "Club Soda", 2, "oz" ]
      ],
      instructions:
        "Shake the gin, lemon juice, and syrup with ice. Strain over fresh ice and top with club soda."
    },

    "French 75" => {
      ingredients: [
        [ "Gin", 1, "oz" ],
        [ "Lemon Juice", 0.5, "oz" ],
        [ "Simple Syrup", 0.5, "oz" ],
        [ "Champagne", 3, "oz" ]
      ],
      instructions:
        "Shake the gin, lemon juice, and syrup with ice. Strain and top with Champagne."
    },

    "Gimlet" => {
      ingredients: [
        [ "Gin", 2, "oz" ],
        [ "Lime Juice", 0.75, "oz" ],
        [ "Simple Syrup", 0.75, "oz" ]
      ],
      instructions:
        "Shake with ice and strain into a chilled glass."
    },

    "Sidecar" => {
      ingredients: [
        [ "Cognac", 2, "oz" ],
        [ "Triple Sec", 0.75, "oz" ],
        [ "Lemon Juice", 0.75, "oz" ]
      ],
      instructions:
        "Shake with ice and strain into a chilled coupe."
    },

    "Boulevardier" => {
      ingredients: [
        [ "Bourbon", 1.5, "oz" ],
        [ "Campari", 1, "oz" ],
        [ "Sweet Vermouth", 1, "oz" ]
      ],
      instructions:
        "Stir with ice and strain over fresh ice."
    },

    "Mai Tai" => {
      ingredients: [
        [ "Aged Rum", 2, "oz" ],
        [ "Lime Juice", 0.75, "oz" ],
        [ "Orange Curaçao", 0.5, "oz" ],
        [ "Orgeat", 0.5, "oz" ]
      ],
      instructions:
        "Shake with ice and pour over crushed ice."
    },

    "Piña Colada" => {
      ingredients: [
        [ "Light Rum", 2, "oz" ],
        [ "Pineapple Juice", 3, "oz" ],
        [ "Coconut Cream", 1.5, "oz" ]
      ],
      instructions:
        "Blend with ice until smooth."
    },

    "Dark and Stormy" => {
      ingredients: [
        [ "Dark Rum", 2, "oz" ],
        [ "Ginger Beer", 4, "oz" ],
        [ "Lime Juice", 0.5, "oz" ]
      ],
      instructions:
        "Build over ice and top with ginger beer."
    },

    "Espresso Martini" => {
      ingredients: [
        [ "Vodka", 2, "oz" ],
        [ "Coffee Liqueur", 0.5, "oz" ],
        [ "Espresso", 1, "oz" ],
        [ "Simple Syrup", 0.25, "oz" ]
      ],
      instructions:
        "Shake hard with ice and double strain into a chilled glass."
    },

    "Cosmopolitan" => {
      ingredients: [
        [ "Citrus Vodka", 1.5, "oz" ],
        [ "Triple Sec", 0.75, "oz" ],
        [ "Cranberry Juice", 0.75, "oz" ],
        [ "Lime Juice", 0.5, "oz" ]
      ],
      instructions:
        "Shake with ice and strain into a chilled cocktail glass."
    },

    "Aperol Spritz" => {
      ingredients: [
        [ "Prosecco", 3, "oz" ],
        [ "Aperol", 2, "oz" ],
        [ "Club Soda", 1, "oz" ]
      ],
      instructions:
        "Build over ice and gently stir."
    },

    "Sazerac" => {
      ingredients: [
        [ "Rye Whiskey", 2, "oz" ],
        [ "Peychaud's Bitters", 3, "dash" ],
        [ "Simple Syrup", 0.25, "oz" ],
        [ "Absinthe", 0.25, "oz" ]
      ],
      instructions:
        "Rinse the glass with absinthe. Stir the remaining ingredients with ice and strain into the glass."
    },

    "Mint Julep" => {
      ingredients: [
        [ "Bourbon", 2.5, "oz" ],
        [ "Simple Syrup", 0.5, "oz" ],
        [ "Mint", 8, "leaf" ]
      ],
      instructions:
        "Combine with crushed ice and gently stir."
    },

    "Penicillin" => {
      ingredients: [
        [ "Blended Scotch", 2, "oz" ],
        [ "Lemon Juice", 0.75, "oz" ],
        [ "Honey Syrup", 0.75, "oz" ],
        [ "Ginger Cordial", 0.25, "oz" ],
        [ "Peated Scotch", 0.25, "oz" ]
      ],
      instructions:
        "Shake everything except the peated Scotch with ice. Strain over fresh ice and float the peated Scotch."
    },

    "Mezcal Negroni" => {
      ingredients: [
        [ "Mezcal", 1, "oz" ],
        [ "Campari", 1, "oz" ],
        [ "Sweet Vermouth", 1, "oz" ]
      ],
      instructions:
        "Stir with ice and strain over fresh ice."
    },

    "Caipirinha" => {
      ingredients: [
        [ "Cachaça", 2, "oz" ],
        [ "Lime", 1, "each" ],
        [ "Simple Syrup", 0.5, "oz" ]
      ],
      instructions:
        "Muddle the lime with syrup, add Cachaça and ice, then stir."
    },

    "Irish Coffee" => {
      ingredients: [
        [ "Irish Whiskey", 1.5, "oz" ],
        [ "Coffee", 4, "oz" ],
        [ "Brown Sugar Syrup", 0.5, "oz" ],
        [ "Heavy Cream", 1, "oz" ]
      ],
      instructions:
        "Combine whiskey, hot coffee, and brown sugar syrup. Float the cream on top."
    },

    "Bee's Knees" => {
      ingredients: [
        [ "Gin", 2, "oz" ],
        [ "Lemon Juice", 0.75, "oz" ],
        [ "Honey Syrup", 0.75, "oz" ]
      ],
      instructions:
        "Shake with ice and strain into a chilled glass."
    },

    "Virgin Mojito" => {
      ingredients: [
        [ "Lime Juice", 0.75, "oz" ],
        [ "Simple Syrup", 0.5, "oz" ],
        [ "Mint", 8, "leaf" ],
        [ "Club Soda", 3, "oz" ]
      ],
      instructions:
        "Combine lime juice, syrup, and mint over ice. Top with club soda."
    },

    "Shirley Temple" => {
      ingredients: [
        [ "Lemon-Lime Soda", 4, "oz" ],
        [ "Grenadine", 0.5, "oz" ]
      ],
      instructions:
        "Build over ice and gently stir."
    },

    "Virgin Piña Colada" => {
      ingredients: [
        [ "Pineapple Juice", 3, "oz" ],
        [ "Coconut Cream", 1.5, "oz" ]
      ],
      instructions:
        "Blend with ice until smooth."
    },

    "Roy Rogers" => {
      ingredients: [
        [ "Cola", 4, "oz" ],
        [ "Grenadine", 0.5, "oz" ]
      ],
      instructions:
        "Build over ice and gently stir."
    },

    "Cucumber Cooler" => {
      ingredients: [
        [ "Cucumber Juice", 2, "oz" ],
        [ "Lime Juice", 0.75, "oz" ],
        [ "Simple Syrup", 0.5, "oz" ],
        [ "Club Soda", 2, "oz" ]
      ],
      instructions:
        "Shake everything except the club soda with ice. Strain over fresh ice and top with soda."
    },

    "Ginger Lime Fizz" => {
      ingredients: [
        [ "Ginger Beer", 4, "oz" ],
        [ "Lime Juice", 0.75, "oz" ],
        [ "Simple Syrup", 0.25, "oz" ]
      ],
      instructions:
        "Build over ice and gently stir."
    },

    "Pineapple Mint Cooler" => {
      ingredients: [
        [ "Pineapple Juice", 3, "oz" ],
        [ "Lime Juice", 0.5, "oz" ],
        [ "Mint", 6, "leaf" ],
        [ "Club Soda", 2, "oz" ]
      ],
      instructions:
        "Shake pineapple juice, lime juice, and mint with ice. Strain and top with club soda."
    },

    "Grapefruit Spritz" => {
      ingredients: [
        [ "Grapefruit Juice", 3, "oz" ],
        [ "Simple Syrup", 0.5, "oz" ],
        [ "Club Soda", 2, "oz" ]
      ],
      instructions:
        "Build over ice and gently stir."
    }
  }.freeze

  def self.call
    new.call
  end

  def call
    if User.exists?(seeded_account: true)
      raise(
        "Seeded demo accounts already exist. " \
        "Run bin/rails demo_data:clear first."
      )
    end

    validate_reference_data!

    puts "Generating #{USER_COUNT} seeded demo accounts..."

    User.transaction do
      USER_COUNT.times do |index|
        user = create_user(index)

        drink_count =
          drink_count_for(index)

        drinks =
          create_drinks_for(
            user,
            drink_count
          )

        create_recipes_for(
          user,
          drinks,
          drink_count
        )
      end
    end

    puts(
      "Created " \
      "#{User.where(seeded_account: true).count} " \
      "seeded demo accounts."
    )

    puts(
      "Created " \
      "#{seeded_drink_count} " \
      "seeded drinks."
    )

    puts(
      "Created " \
      "#{seeded_recipe_count} " \
      "seeded recipes."
    )

    puts(
      "Created " \
      "#{seeded_recipe_ingredient_count} " \
      "seeded recipe ingredients."
    )
  end

  private

  def create_user(index)
    first_name =
      FIRST_NAMES[
        index % FIRST_NAMES.length
      ]

    last_name =
      LAST_NAMES[
        index % LAST_NAMES.length
      ]

    username =
      "#{first_name}#{last_name}"
        .downcase
        .gsub(/[^a-z0-9]/, "")

    created_at =
      Time.current -
      rand(30..420).days -
      rand(0..23).hours -
      rand(0..59).minutes

    password =
      SecureRandom.base64(32)

    User.create!(
      name:
        "#{first_name} #{last_name}",

      username: username,

      email:
        "#{username}@example.com",

      password: password,

      password_confirmation:
        password,

      seeded_account: true,

      created_at: created_at,
      updated_at: created_at
    )
  end

  def create_drinks_for(
    user,
    drink_count
  )
    DRINK_CATALOG
      .sample(drink_count)
      .map do |drink_data|
        created_at =
          random_time_between(
            user.created_at,
            Time.current
          )

        Drink.create!(
          user: user,

          name:
            drink_data[:name],

          alcoholic:
            drink_data[:alcoholic],

          publicly_visible: true,

          categories:
            categories_for(
              drink_data
            ),

          created_at: created_at,
          updated_at: created_at
        )
      end
  end

  def create_recipes_for(
    user,
    drinks,
    drink_count
  )
    drinks.each do |drink|
      template =
        RECIPE_CATALOG.fetch(
          drink.name
        )

      recipe_count =
        recipe_count_for(
          drink_count
        )

      recipe_count.times do |index|
        create_recipe(
          user,
          drink,
          template,
          index
        )
      end
    end
  end

  def create_recipe(
    user,
    drink,
    template,
    index
  )
    created_at =
      random_time_between(
        drink.created_at,
        Time.current
      )

    recipe =
      Recipe.create!(
        drink: drink,

        name:
          recipe_name(
            user,
            drink,
            index
          ),

        instructions:
          template[:instructions],

        publicly_visible: true,

        created_at: created_at,
        updated_at: created_at
      )

    template[:ingredients].each do |
      ingredient_name,
      amount,
      unit
    |
      RecipeIngredient.create!(
        recipe: recipe,

        ingredient:
          ingredient_for(
            ingredient_name
          ),

        amount: amount,

        measurement_unit:
          unit,

        created_at: created_at,
        updated_at: created_at
      )
    end

    recipe
  end

  def recipe_name(
    user,
    drink,
    index
  )
    first_name =
      user.name.split.first

    case index
    when 0
      "Classic #{drink.name}"
    when 1
      "#{first_name}'s #{drink.name}"
    else
      "House #{drink.name}"
    end
  end

  def recipe_count_for(
    drink_count
  )
    return 1 if drink_count == 1
    return 3 if drink_count >= 20

    roll = rand(1..100)

    case roll
    when 1..55
      1
    when 56..85
      2
    else
      3
    end
  end

  def categories_for(drink_data)
    [
      category_for(drink_data[:category])
    ]
  end

  def category_for(slug)
    categories.fetch(slug)
  end

  def ingredient_for(name)
    ingredients.fetch(name)
  end

  def categories
    @categories ||=
      Category
        .where(
          slug:
            required_category_slugs
        )
        .index_by(&:slug)
  end

  def ingredients
    @ingredients ||=
      Ingredient
        .where(
          user_id: nil,
          name:
            required_ingredient_names
        )
        .index_by(&:name)
  end

  def validate_reference_data!
    missing_categories =
      required_category_slugs -
      categories.keys

    missing_ingredients =
      required_ingredient_names -
      ingredients.keys

    if missing_categories.any?
      raise(
        "Missing demo-data categories: " \
        "#{missing_categories.join(', ')}"
      )
    end

    if missing_ingredients.any?
      raise(
        "Missing demo-data ingredients: " \
        "#{missing_ingredients.join(', ')}"
      )
    end
  end

  def required_category_slugs
    @required_category_slugs ||=
      DRINK_CATALOG
        .map { |drink| drink[:category] }
        .uniq
  end

  def required_ingredient_names
    @required_ingredient_names ||=
      RECIPE_CATALOG
        .values
        .flat_map {
          |recipe|
          recipe[:ingredients]
        }
        .map(&:first)
        .uniq
  end

  def drink_count_for(index)
    case index
    when 0
      26
    when 1
      20
    when 2
      15
    when 3
      1
    else
      weighted_drink_count
    end
  end

  def weighted_drink_count
    roll = rand(1..100)

    case roll
    when 1..55
      rand(1..5)
    when 56..80
      rand(6..10)
    when 81..93
      rand(11..15)
    else
      rand(16..20)
    end
  end

  def random_time_between(
    start_time,
    end_time
  )
    Time.at(
      rand(
        start_time.to_f..
        end_time.to_f
      )
    )
  end

  def seeded_drink_count
    Drink
      .joins(:user)
      .where(
        users: {
          seeded_account: true
        }
      )
      .count
  end

  def seeded_recipe_count
    Recipe
      .joins(
        drink: :user
      )
      .where(
        users: {
          seeded_account: true
        }
      )
      .count
  end

  def seeded_recipe_ingredient_count
    RecipeIngredient
      .joins(
        recipe: {
          drink: :user
        }
      )
      .where(
        users: {
          seeded_account: true
        }
      )
      .count
  end
end
