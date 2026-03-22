require "rails_helper"

RSpec.describe "Api::V1::Dev::SimulatedPayments", type: :request do
  describe "POST /api/v1/dev/simulated_payments/:provider_payment_id/approve" do
    it "manually approves a pending payment" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-TEST-123")
      product = create(:product)
      create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      post "/api/v1/dev/simulated_payments/SIM-TEST-123/approve"

      expect(response).to have_http_status(:ok)
      expect(payment.reload).to be_completed
      expect(order.reload).to be_processing
      expect(json_data[:message]).to eq("Payment approved")
    end

    it "returns 404 for unknown payment" do
      post "/api/v1/dev/simulated_payments/UNKNOWN/approve"

      expect(response).to have_http_status(:not_found)
    end

    it "is disabled in production" do
      allow(Rails.env).to receive_messages(test?: false, development?: false, production?: true)

      post "/api/v1/dev/simulated_payments/SIM-123/approve"

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/dev/simulated_payments/:provider_payment_id/reject" do
    it "manually rejects a pending payment" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-TEST-456")

      post "/api/v1/dev/simulated_payments/SIM-TEST-456/reject"

      expect(response).to have_http_status(:ok)
      expect(payment.reload).to be_failed
      expect(json_data[:message]).to eq("Payment rejected")
    end

    it "is disabled in production" do
      allow(Rails.env).to receive_messages(test?: false, development?: false, production?: true)

      post "/api/v1/dev/simulated_payments/SIM-123/reject"

      expect(response).to have_http_status(:forbidden)
    end
  end
end
