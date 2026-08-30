require "rails_helper"

RSpec.describe "Profile Recipes API", type: :request do
  before(:each) do
    @viewer = User.create!(
      name: "Viewer",
      username: "viewer",
      email: "viewer@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @profile_user = User.create!(
      name: "Alice",
      username: "alice",
      email: "alice@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @other_user = User.create!(
      name: "Bob",
      username: "bob",
      email: "bob@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @category = Category.create!(
      name: "Whiskey",
      slug: "whiskey"
    )

    @public_drink =
      create_drink(
        user: @profile_user,
        name: "Public Old Fashioned"
      )

    @private_drink =
      create_drink(
        user: @profile_user,
        name: "Private Manhattan",
        publicly_visible: false
      )

    @other_drink =
      create_drink(
        user: @other_user,
        name: "Bob's Negroni"
      )
  end

  def log_in(user)
    post "/api/v1/login",
         params: {
           email: user.email,
           password: "password123"
         }
  end

  def create_drink(
    user:,
    name:,
    publicly_visible: true
  )
    user.drinks.create!(
      name: name,
      category_slugs: [
        @category.slug
      ],
      alcoholic: true,
      publicly_visible:
        publicly_visible
    )
  end

  def create_recipe(
    drink:,
    name:,
    publicly_visible: true
  )
    drink.recipes.create!(
      name: name,
      instructions:
        "Stir and serve.",
      publicly_visible:
        publicly_visible
    )
  end

  describe "happy path" do
    describe "GET /api/v1/profiles/:profile_username/recipes" do
      it "returns only public recipes created by the profile user" do
        public_recipe =
          create_recipe(
            drink: @public_drink,
            name: "Public Recipe"
          )

        private_recipe =
          create_recipe(
            drink: @public_drink,
            name: "Private Recipe",
            publicly_visible: false
          )

        recipe_on_private_drink =
          create_recipe(
            drink: @private_drink,
            name:
              "Recipe On Private Drink"
          )

        other_recipe =
          create_recipe(
            drink: @other_drink,
            name: "Bob's Recipe"
          )

        log_in(@viewer)

        get "/api/v1/profiles/alice/recipes"

        result =
          JSON.parse(response.body)

        recipe_ids =
          result["recipes"].map do |recipe|
            recipe["id"]
          end

        expect(response).to have_http_status(:ok)

        expect(recipe_ids).to include(
          public_recipe.id
        )

        expect(recipe_ids).not_to include(
          private_recipe.id
        )

        expect(recipe_ids).not_to include(
          recipe_on_private_drink.id
        )

        expect(recipe_ids).not_to include(
          other_recipe.id
        )
      end

      it "paginates profile recipes ten at a time" do
        11.times do |number|
          create_recipe(
            drink: @public_drink,
            name:
              "Profile Recipe #{number}"
          )
        end

        log_in(@viewer)

        get "/api/v1/profiles/alice/recipes",
            params: {
              page: 1
            }

        result =
          JSON.parse(response.body)

        expect(
          result["recipes"].count
        ).to eq(10)

        expect(
          result["pagination"]
        ).to include(
          "page" => 1,
          "per_page" => 10,
          "total_count" => 11,
          "total_pages" => 2,
          "has_previous" => false,
          "has_next" => true
        )
      end
    end
  end

  describe "sad path" do
    describe "GET /api/v1/profiles/:profile_username/recipes" do
      it "does not allow an unauthenticated user to view profile recipes" do
        get "/api/v1/profiles/alice/recipes"

        expect(response).to have_http_status(
          :unauthorized
        )
      end

      it "returns not found when the profile does not exist" do
        log_in(@viewer)

        get "/api/v1/profiles/not-a-user/recipes"

        expect(response).to have_http_status(
          :not_found
        )
      end
    end
  end
end
