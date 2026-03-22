require "rails_helper"

RSpec.describe "Api::V1::Payments", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "POST /api/v1/orders/:order_number/pay" do
    it "creates a payment and returns payment URL" do
      order = create(:order, customer_profile: profile)

      authenticated_post "/api/v1/orders/#{order.order_number}/pay",
        customer_profile: profile

      expect(response).to have_http_status(:created)
      expect(json_data[:payment_url]).to be_present
      expect(json_data[:amount]).to eq(order.total.to_s)
      expect(json_data[:currency]).to eq("MXN")
    end

    it "returns 401 without authentication" do
      order = create(:order)

      post "/api/v1/orders/#{order.order_number}/pay"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 404 for another user's order" do
      other_order = create(:order)

      authenticated_post "/api/v1/orders/#{other_order.order_number}/pay",
        customer_profile: profile

      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 if payment already exists" do
      order = create(:order, customer_profile: profile)
      create(:payment, order: order)

      authenticated_post "/api/v1/orders/#{order.order_number}/pay",
        customer_profile: profile

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
