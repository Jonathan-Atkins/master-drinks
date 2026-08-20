Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :categories, only: [ :index ]

      resources :drinks do
        resources :recipes
      end

      resources :recipes, except: [ :create ] do
        resources :recipe_ingredients, only: [ :create ]
      end

      resources :recipe_ingredients, only: [ :update, :destroy ]

      resources :users do
        member do
          patch :password
        end
      end

      resources :ingredients
      resources :user_recipes, only: [ :index, :create, :destroy ]

      post "/login", to: "sessions#create"
      delete "/logout", to: "sessions#destroy"
      get "/session", to: "sessions#show"
      get "/my_recipes", to: "my_recipes#index"
      get "/my_drinks", to: "my_drinks#index"

      # namespace :admin do
      #   resources :drinks
      #   resources :recipes
      #   resources :ingredients
      # end
    end
  end
end