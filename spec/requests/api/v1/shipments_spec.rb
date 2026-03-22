require "rails_helper"

RSpec.describe "Api::V1::Shipments", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "GET /api/v1/orders/:order_number/shipment" do
    it "returns shipment details" do
      order = create(:order, :shipped, customer_profile: profile)
      create(:shipment, order: order, carrier: "DHL", tracking_number: "ABC123")

      authenticated_get "/api/v1/orders/#{order.order_number}/shipment", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data[:attributes][:carrier]).to eq("DHL")
      expect(json_data[:attributes][:tracking_number]).to eq("ABC123")
    end

    it "returns 404 when no shipment exists" do
      order = create(:order, customer_profile: profile)

      authenticated_get "/api/v1/orders/#{order.order_number}/shipment", customer_profile: profile

      expect(response).to have_http_status(:not_found)
    end
  end
end
