require "rails_helper"

RSpec.describe "Api::V1::Orders", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "GET /api/v1/orders" do
    it "returns 401 without authentication" do
      get "/api/v1/orders"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns user orders" do
      create(:order, customer_profile: profile)
      create(:order) # another user's order

      authenticated_get "/api/v1/orders", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end
  end

  describe "GET /api/v1/orders/:order_number" do
    it "returns order detail" do
      order = create(:order, customer_profile: profile)
      create(:order_item, order: order)

      authenticated_get "/api/v1/orders/#{order.order_number}", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data[:attributes][:order_number]).to eq(order.order_number)
      expect(json_data[:attributes][:items]).to be_present
    end

    it "returns 404 for another user's order" do
      other_order = create(:order)

      authenticated_get "/api/v1/orders/#{other_order.order_number}", customer_profile: profile

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/orders" do
    it "creates an order from the cart" do
      product = create(:product, price: 500.00)
      create(:inventory, product: product, stock: 10)
      create(:cart_item, customer_profile: profile, product: product, quantity: 2)
      address = create(:address, customer_profile: profile)

      authenticated_post "/api/v1/orders",
        customer_profile: profile,
        params: {
          address_id: address.id,
          customer_name: "Test User",
          customer_email: "test@example.com"
        }

      expect(response).to have_http_status(:created)
      expect(json_data[:attributes][:status]).to eq("pending")
      expect(json_data[:attributes][:order_number]).to match(/\ACRA-/)
    end

    it "returns 422 for empty cart" do
      address = create(:address, customer_profile: profile)

      authenticated_post "/api/v1/orders",
        customer_profile: profile,
        params: {
          address_id: address.id,
          customer_name: "Test",
          customer_email: "test@example.com"
        }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 for insufficient stock" do
      product = create(:product, price: 100)
      create(:inventory, product: product, stock: 1)
      create(:cart_item, customer_profile: profile, product: product, quantity: 5)
      address = create(:address, customer_profile: profile)

      authenticated_post "/api/v1/orders",
        customer_profile: profile,
        params: {
          address_id: address.id,
          customer_name: "Test",
          customer_email: "test@example.com"
        }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_error[:code]).to eq("insufficient_stock")
    end
  end
end
