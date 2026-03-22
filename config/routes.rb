Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"

      get "products/search", to: "products#search", as: :products_search

      resources :products, only: %i[index show], param: :slug do
        resources :reviews, only: %i[index create]
      end

      resources :categories, only: %i[index show], param: :slug

      resource :cart, only: [ :show ], controller: "cart" do
        post :sync, on: :collection
        resources :items, only: [ :create, :update, :destroy ], controller: "cart", as: :cart_items
      end

      resource :wishlist, only: [ :show ], controller: "wishlist" do
        resources :items, only: [ :create, :destroy ], controller: "wishlist", as: :wishlist_items
      end

      resource :profile, only: [ :show, :update ], controller: "profile"

      resources :addresses, only: [ :index, :create, :update, :destroy ]

      resources :orders, only: %i[index show create], param: :order_number do
        get "shipment", to: "shipments#show", on: :member
      end
    end
  end
end
