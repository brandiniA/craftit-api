Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"

      get "products/search", to: "products#search", as: :products_search

      resources :products, only: %i[index show], param: :slug do
        get "reviews", to: "reviews#index", on: :member
      end

      resources :categories, only: %i[index show], param: :slug
    end
  end
end
