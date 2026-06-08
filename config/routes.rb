Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :drinks, only: [:index, :create, :show, :update]
    end
  end
end
