require "rails_helper"

RSpec.describe "Api::V1::Ingredients", type: :request do
  before(:each) do
    @user = User.create!(
      name: "Alice",
      username: "alice",
      email: "alice@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @drink = @user.drinks.create!(
      name: "Old Fashioned",
      category: "whiskey",
      alcoholic: true
    )

    @ingredient = Ingredient.create!(
      name: "Bourbon"
    )
  end

  def log_in(user)
    post "/api/v1/login", params: {
      email: user.email,
      password: "password123"
    }
  end

  describe "happy path" do
    describe "GET /api/v1/ingredients" do
      it "returns all ingredients without requiring authentication" do
        Ingredient.create!(name: "Bitters")

        get "/api/v1/ingredients"

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)

        expect(result.count).to eq(2)
        expect(result.pluck("name")).to contain_exactly(
          "Bourbon",
          "Bitters"
        )
      end
    end

    describe "GET /api/v1/ingredients/:id" do
      it "returns one ingredient without requiring authentication" do
        get "/api/v1/ingredients/#{@ingredient.id}"

        expect(response).to have_http_status(:ok)

        result = JSON.parse(response.body)
        
        expect(result["id"]).to eq(@ingredient[:id])
        expect(result["name"]).to eq("Bourbon")
      end
    end

    describe "POST /api/v1/ingredients" do
      it "allows an authenticated user to create an ingredient" do
        log_in(@user)

          post "/api/v1/ingredients", params: {
            name: "Simple Syrup"
          }

          expect(response).to have_http_status(:created)
          
          result = JSON.parse(response.body)
          
          expect(result["name"]).to eq("Simple Syrup")
          expect(Ingredient.last.name).to eq("Simple Syrup")
        end
    end

    #   describe "PATCH /api/v1/ingredients/:id" do
    #     it "allows an authenticated user to update an ingredient" do
    #       log_in(@user)

    #       patch "/api/v1/ingredients/#{@ingredient.id}", params: {
    #         name: "Rye Whiskey"
    #       }

    #       expect(response).to have_http_status(:ok)

    #       result = JSON.parse(response.body)

    #       expect(result["name"]).to eq("Rye Whiskey")
    #       expect(@ingredient.reload.name).to eq("Rye Whiskey")
    #     end
    #   end

    #   describe "DELETE /api/v1/ingredients/:id" do
    #     it "allows an authenticated user to delete an ingredient" do
    #       log_in(@user)

    #       expect {
    #         delete "/api/v1/ingredients/#{@ingredient.id}"
    #       }.to change(Ingredient, :count).by(-1)

    #       expect(response).to have_http_status(:no_content)
    #     end
    #   end
    # end

    # describe "sad path" do
    #   describe "GET /api/v1/ingredients/:id" do
    #     it "returns 404 when the ingredient does not exist" do
    #       get "/api/v1/ingredients/999999"

    #       expect(response).to have_http_status(:not_found)
    #     end
    #   end

      describe "POST /api/v1/ingredients" do
        it "does not allow an unauthenticated user to create an ingredient" do
          post "/api/v1/ingredients", params: {
            name: "Simple Syrup"
          }

          expect(response).to have_http_status(:unauthorized)
          expect(Ingredient.find_by(name: "Simple Syrup")).to be_nil
        end

        it "does not create an ingredient with invalid attributes" do
          log_in(@user)

          post "/api/v1/ingredients", params: {
            name: nil
          }

          expect(response).to have_http_status(:unprocessable_content)

          result = JSON.parse(response.body)

          expect(result["errors"]).to include("Name can't be blank")
        end
      end

    #   describe "PATCH /api/v1/ingredients/:id" do
    #     it "does not allow an unauthenticated user to update an ingredient" do
    #       patch "/api/v1/ingredients/#{@ingredient.id}", params: {
    #         name: "Rye Whiskey"
    #       }

    #       expect(response).to have_http_status(:unauthorized)
    #       expect(@ingredient.reload.name).to eq("Bourbon")
    #     end

    #     it "does not update an ingredient with invalid attributes" do
    #       log_in(@user)

    #       patch "/api/v1/ingredients/#{@ingredient.id}", params: {
    #         name: nil
    #       }

    #       expect(response).to have_http_status(:unprocessable_content)
    #       expect(@ingredient.reload.name).to eq("Bourbon")
    #     end
    #   end

    # describe "DELETE /api/v1/ingredients/:id" do
    #   it "does not allow an unauthenticated user to delete an ingredient" do
    #     expect {
    #       delete "/api/v1/ingredients/#{@ingredient.id}"
    #     }.not_to change(Ingredient, :count)

    #     expect(response).to have_http_status(:unauthorized)
    #   end
    # end
  end
end
