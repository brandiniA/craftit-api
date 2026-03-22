require "rails_helper"

RSpec.describe "Api::V1::Admin::Orders", type: :request do
  before { ENV["ADMIN_EMAIL"] = "admin@craftitapp.com" }

  describe "GET /api/v1/admin/orders" do
    it "returns all orders" do
      create_list(:order, 3)

      admin_get "/api/v1/admin/orders"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
    end

    it "filters by status" do
      create(:order, :paid)
      create(:order, :pending)

      admin_get "/api/v1/admin/orders", params: { status: "paid" }

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end
  end

  describe "PATCH /api/v1/admin/orders/:id/status" do
    it "transitions order status" do
      order = create(:order, :paid)

      admin_patch "/api/v1/admin/orders/#{order.id}/status",
        params: { status: "processing" }

      expect(response).to have_http_status(:ok)
      expect(order.reload.status).to eq("processing")
    end

    it "returns 422 for invalid transition" do
      order = create(:order, :delivered)

      admin_patch "/api/v1/admin/orders/#{order.id}/status",
        params: { status: "cancelled" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /api/v1/admin/orders/:id/shipment" do
    it "creates a shipment and transitions order to shipped" do
      order = create(:order, :processing)

      admin_post "/api/v1/admin/orders/#{order.id}/shipment",
        params: {
          carrier: "DHL",
          tracking_number: "DHL123456",
          tracking_url: "https://dhl.com/track/DHL123456",
          estimated_delivery: "2026-03-29"
        }

      expect(response).to have_http_status(:created)
      expect(order.reload.status).to eq("shipped")
      expect(order.shipment.carrier).to eq("DHL")
    end
  end
end
