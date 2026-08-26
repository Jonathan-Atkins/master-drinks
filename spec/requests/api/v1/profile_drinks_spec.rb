require "rails_helper"

RSpec.describe "Profile Drinks API", type: :request do
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

  describe "happy path" do
    describe "GET /api/v1/profiles/:profile_username/drinks" do
      it "returns only public drinks owned by the profile user" do
        public_drink =
          create_drink(
            user: @profile_user,
            name: "Public Old Fashioned"
          )

        private_drink =
          create_drink(
            user: @profile_user,
            name: "Private Manhattan",
            publicly_visible: false
          )

        other_drink =
          create_drink(
            user: @other_user,
            name: "Bob's Negroni"
          )

        log_in(@viewer)

        get "/api/v1/profiles/alice/drinks"

        result =
          JSON.parse(response.body)

        drink_ids =
          result["drinks"].map do |drink|
            drink["id"]
          end

        expect(response).to have_http_status(:ok)

        expect(drink_ids).to include(
          public_drink.id
        )

        expect(drink_ids).not_to include(
          private_drink.id
        )

        expect(drink_ids).not_to include(
          other_drink.id
        )
      end

      it "paginates profile drinks ten at a time" do
        11.times do |number|
          create_drink(
            user: @profile_user,
            name:
              "Profile Drink #{number}"
          )
        end

        log_in(@viewer)

        get "/api/v1/profiles/alice/drinks",
            params: {
              page: 1
            }

        result =
          JSON.parse(response.body)

        expect(
          result["drinks"].count
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
    describe "GET /api/v1/profiles/:profile_username/drinks" do
      it "does not allow an unauthenticated user to view profile drinks" do
        get "/api/v1/profiles/alice/drinks"

        expect(response).to have_http_status(
          :unauthorized
        )
      end

      it "returns not found when the profile does not exist" do
        log_in(@viewer)

        get "/api/v1/profiles/not-a-user/drinks"

        expect(response).to have_http_status(
          :not_found
        )
      end
    end
  end
end