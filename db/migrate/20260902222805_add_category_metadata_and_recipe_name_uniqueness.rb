class AddCategoryMetadataAndRecipeNameUniqueness <
  ActiveRecord::Migration[8.1]
  NONALCOHOLIC_CATEGORIES = [
    "Nonalcoholic Spirit",
    "Nonalcoholic Aperitif",
    "Nonalcoholic Vermouth",
    "Nonalcoholic Beer",
    "Nonalcoholic Sparkling Wine"
  ].freeze

  WINE_CATEGORIES = [
    "Wine",
    "Red Wine",
    "White Wine",
    "Rose Wine",
    "Fortified Wine",
    "Port",
    "Sherry",
    "Madeira",
    "Marsala",
    "Champagne",
    "Sparkling Wine",
    "Prosecco",
    "Nonalcoholic Vermouth",
    "Nonalcoholic Sparkling Wine"
  ].freeze

  BEER_CATEGORIES = [
    "Beer",
    "Cider",
    "Nonalcoholic Beer"
  ].freeze

  LIQUEUR_CATEGORIES = [
    "Liqueur",
    "Amaro",
    "Aperitif",
    "Vermouth",
    "Nonalcoholic Aperitif"
  ].freeze

  class MigrationCategory <
    ActiveRecord::Base
    self.table_name = "categories"

    has_many(
      :drink_categories,
      class_name:
        "AddCategoryMetadataAndRecipeNameUniqueness::MigrationDrinkCategory",
      foreign_key: :category_id
    )
  end

  class MigrationIngredient <
    ActiveRecord::Base
    self.table_name = "ingredients"
  end

  class MigrationDrinkCategory <
    ActiveRecord::Base
    self.table_name = "drink_categories"
  end

  class MigrationDrink <
    ActiveRecord::Base
    self.table_name = "drinks"
  end

  class MigrationRecipe <
    ActiveRecord::Base
    self.table_name = "recipes"
  end

  def up
    add_column(
      :categories,
      :alcoholic,
      :boolean,
      default: true,
      null: false
    )

    add_reference(
      :categories,
      :ingredient,
      foreign_key: true,
      null: true
    )

    migrate_nonalcoholic_categories
    connect_categories_to_ingredients
    reconcile_existing_drinks
    normalize_existing_recipe_names

    change_column_null(
      :categories,
      :ingredient_id,
      false
    )

    change_column_null(
      :recipes,
      :name,
      false
    )

    add_index(
      :recipes,
      "drink_id, LOWER(name)",
      unique: true,
      name:
        "index_recipes_on_drink_id_and_lower_name"
    )
  end

  def down
    remove_index(
      :recipes,
      name:
        "index_recipes_on_drink_id_and_lower_name"
    )

    remove_reference(
      :categories,
      :ingredient,
      foreign_key: true
    )

    remove_column(
      :categories,
      :alcoholic
    )
  end

  private

  def migrate_nonalcoholic_categories
    legacy_category =
      MigrationCategory.find_by(
        name: "Non Alcoholic"
      )

    target_category =
      MigrationCategory.find_by(
        name: "Nonalcoholic Spirit"
      )

    if legacy_category &&
       target_category
      merge_category_relationships(
        legacy_category,
        target_category
      )

      legacy_category.destroy!
    elsif legacy_category
      legacy_category.update_columns(
        name: "Nonalcoholic Spirit",
        slug: "nonalcoholic-spirit",
        alcoholic: false,
        updated_at: Time.current
      )
    end

    NONALCOHOLIC_CATEGORIES.each do |name|
      category =
        MigrationCategory.find_or_initialize_by(
          name: name
        )

      category.slug =
        name.parameterize

      category.alcoholic =
        false

      category.save!
    end

    MigrationCategory
      .where
      .not(
        name:
          NONALCOHOLIC_CATEGORIES
      )
      .update_all(
        alcoholic: true
      )
  end

  def merge_category_relationships(
    source_category,
    target_category
  )
    source_category
      .drink_categories
      .find_each do |drink_category|
      existing_relationship =
        MigrationDrinkCategory.exists?(
          drink_id:
            drink_category.drink_id,
          category_id:
            target_category.id
        )

      if existing_relationship
        drink_category.destroy!
      else
        drink_category.update!(
          category_id:
            target_category.id
        )
      end
    end
  end

  def connect_categories_to_ingredients
    MigrationCategory
      .order(:id)
      .find_each do |category|
      ingredient =
        MigrationIngredient.find_by(
          "LOWER(name) = ?",
          category.name.downcase
        )

      ingredient ||=
        MigrationIngredient.create!(
          name: category.name,
          ingredient_type:
            ingredient_type_for(
              category.name
            ),
          flavor_profiles: [],
          user_id: nil,
          created_at: Time.current,
          updated_at: Time.current
        )

      category.update_columns(
        ingredient_id:
          ingredient.id,
        updated_at:
          Time.current
      )
    end
  end

  def ingredient_type_for(name)
    if WINE_CATEGORIES.include?(name)
      "Wine"
    elsif BEER_CATEGORIES.include?(name)
      "Beer"
    elsif LIQUEUR_CATEGORIES.include?(name)
      "Liqueur"
    else
      "Spirit"
    end
  end

  def reconcile_existing_drinks
    nonalcoholic_default =
      MigrationCategory.find_by!(
        name: "Nonalcoholic Spirit"
      )

    MigrationDrink.find_each do |drink|
      category_ids =
        MigrationDrinkCategory
          .where(drink_id: drink.id)
          .pluck(:category_id)

      categories =
        MigrationCategory.where(
          id: category_ids
        )

      matching_categories =
        categories.where(
          alcoholic:
            drink.alcoholic
        )

      if matching_categories.exists?
        invalid_category_ids =
          categories
            .where.not(
              alcoholic:
                drink.alcoholic
            )
            .pluck(:id)

        MigrationDrinkCategory
          .where(
            drink_id: drink.id,
            category_id:
              invalid_category_ids
          )
          .delete_all

        next
      end

      next if drink.alcoholic?

      MigrationDrinkCategory
        .where(
          drink_id: drink.id
        )
        .delete_all

      MigrationDrinkCategory.create!(
        drink_id: drink.id,
        category_id:
          nonalcoholic_default.id,
        created_at: Time.current,
        updated_at: Time.current
      )
    end
  end

  def normalize_existing_recipe_names
    MigrationDrink.find_each do |drink|
      used_names = []

      MigrationRecipe
        .where(drink_id: drink.id)
        .order(:id)
        .find_each do |recipe|
        base_name =
          recipe.name
            .to_s
            .squish
            .presence ||
          drink.name.to_s.squish

        candidate =
          base_name

        number = 2

        while used_names.include?(
          candidate.downcase
        )
          candidate =
            "#{base_name} (#{number})"

          number += 1
        end

        recipe.update_columns(
          name: candidate,
          updated_at:
            Time.current
        )

        used_names <<
          candidate.downcase
      end
    end
  end
end
