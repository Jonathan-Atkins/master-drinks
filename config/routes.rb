Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      root "drinks#index"

      resources :drinks do
        resources :recipes
      end

      resources :recipes,
                except: [ :create ] do
        resources :recipe_ingredients,
                  only: [ :create ]
      end

      resources :recipe_ingredients,
                only: [
                  :update,
                  :destroy
                ]

      resources :users do
        resource :password,
                 only: [ :update ],
                 controller: :passwords
      end

      resources :profiles,
                only: [ :show ],
                param: :username do
        resources :drinks,
                  only: [ :index ],
                  module: :profiles

        resources :recipes,
                  only: [ :index ],
                  module: :profiles
      end

      resources :categories,
                only: [ :index ]

      resources :ingredients

      resources :ingredient_options,
                only: [ :index ]

      resources :user_recipes,
                only: [
                  :index,
                  :create,
                  :destroy
                ]

      resource :account,
               only: [ :destroy ]
               
      resources :fun_facts, only: [ :index ]

      post "/login",
           to: "sessions#create"

      delete "/logout",
             to: "sessions#destroy"

      get "/session",
          to: "sessions#show"

      get "/my_recipes",
          to: "my_recipes#index"

      get "/my_drinks",
          to: "my_drinks#index"
    end
  end
end