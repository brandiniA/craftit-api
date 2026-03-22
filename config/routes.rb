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
        post "pay", on: :member, to: "payments#create"
        get "shipment", to: "shipments#show", on: :member
      end

      post "webhooks/payment", to: "webhooks#payment"

      namespace :dev do
        post "simulated_payments/:provider_payment_id/approve", to: "simulated_payments#approve"
        post "simulated_payments/:provider_payment_id/reject", to: "simulated_payments#reject"
      end

      namespace :admin do
        get "dashboard/stats", to: "dashboard#stats"

        resources :products, only: %i[index create update destroy] do
          post :images, on: :member
        end

        resources :orders, only: [ :index ] do
          patch :status, on: :member
          post :shipment, on: :member
        end

        resources :inventory, only: %i[index update], controller: "inventory" do
          get :low_stock, on: :collection, path: "low-stock"
        end

        resources :customers, only: %i[index show]
      end
    end
  end
end
