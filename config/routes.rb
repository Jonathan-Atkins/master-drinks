Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :drinks, only: [ :index, :create, :show, :update, :destroy ]
      resources :users, only: [ :index, :create, :show ]
    end
  end
end
