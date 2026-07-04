Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :drinks, only: [ :index, :create, :show, :update, :destroy ] do
        resources :recipes, only: [ :index, :create, :show, :update, :destroy ]
      end

      resources :recipes, only: [ :index, :show, :update, :destroy ] do
        resources :recipe_ingredients, only: [ :create ]
      end

      resources :recipe_ingredients, only: [ :update, :destroy ]
      resources :users, only: [ :index, :create, :show, :update, :destroy ]
      resources :ingredients, only: [ :index, :create, :show, :update, :destroy ]
      resources :user_recipes, only: [ :index, :create, :destroy ]

      post "/login", to: "sessions#create"
      delete "/logout", to: "sessions#destroy"
    end
  end
end
