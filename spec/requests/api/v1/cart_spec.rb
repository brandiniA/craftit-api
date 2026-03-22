require "rails_helper"

RSpec.describe "Api::V1::Cart", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "GET /api/v1/cart" do
    it "returns 401 without authentication" do
      get "/api/v1/cart"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns cart items for authenticated user" do
      product = create(:product, :with_inventory)
      create(:cart_item, customer_profile: profile, product: product, quantity: 2)

      authenticated_get "/api/v1/cart", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end

    it "returns empty cart for new user" do
      authenticated_get "/api/v1/cart", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data).to be_empty
    end
  end

  describe "POST /api/v1/cart/items" do
    it "adds a product to cart" do
      product = create(:product, :with_inventory)

      authenticated_post "/api/v1/cart/items",
        customer_profile: profile,
        params: { product_id: product.id, quantity: 2 }

      expect(response).to have_http_status(:created)
      expect(profile.cart_items.count).to eq(1)
      expect(profile.cart_items.first.quantity).to eq(2)
    end

    it "increments quantity if product already in cart" do
      product = create(:product, :with_inventory)
      create(:cart_item, customer_profile: profile, product: product, quantity: 1)

      authenticated_post "/api/v1/cart/items",
        customer_profile: profile,
        params: { product_id: product.id, quantity: 2 }

      expect(response).to have_http_status(:ok)
      expect(profile.cart_items.first.quantity).to eq(3)
    end

    it "returns 422 for invalid quantity" do
      product = create(:product, :with_inventory)

      authenticated_post "/api/v1/cart/items",
        customer_profile: profile,
        params: { product_id: product.id, quantity: 0 }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/cart/items/:id" do
    it "updates cart item quantity" do
      product = create(:product, :with_inventory)
      item = create(:cart_item, customer_profile: profile, product: product, quantity: 1)

      authenticated_patch "/api/v1/cart/items/#{item.id}",
        customer_profile: profile,
        params: { quantity: 5 }

      expect(response).to have_http_status(:ok)
      expect(item.reload.quantity).to eq(5)
    end

    it "cannot update another user's cart item" do
      other_profile = create(:customer_profile)
      item = create(:cart_item, customer_profile: other_profile)

      authenticated_patch "/api/v1/cart/items/#{item.id}",
        customer_profile: profile,
        params: { quantity: 5 }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/cart/items/:id" do
    it "removes item from cart" do
      item = create(:cart_item, customer_profile: profile)

      authenticated_delete "/api/v1/cart/items/#{item.id}", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(profile.cart_items.count).to eq(0)
    end
  end

  describe "POST /api/v1/cart/sync" do
    it "merges local cart items into server cart" do
      product1 = create(:product, :with_inventory)
      product2 = create(:product, :with_inventory)
      create(:cart_item, customer_profile: profile, product: product1, quantity: 1)

      authenticated_post "/api/v1/cart/sync",
        customer_profile: profile,
        params: {
          items: [
            { product_id: product1.id, quantity: 2 },
            { product_id: product2.id, quantity: 1 }
          ]
        }

      expect(response).to have_http_status(:ok)
      expect(profile.cart_items.count).to eq(2)
      expect(profile.cart_items.find_by(product: product1).quantity).to eq(3)
      expect(profile.cart_items.find_by(product: product2).quantity).to eq(1)
    end
  end
end
