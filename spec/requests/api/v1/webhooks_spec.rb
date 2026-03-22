require "rails_helper"

RSpec.describe "Api::V1::Webhooks", type: :request do
  describe "POST /api/v1/webhooks/payment" do
    it "processes approved payment webhook" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-123")
      product = create(:product)
      create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      post "/api/v1/webhooks/payment", params: {
        provider_payment_id: "SIM-123",
        status: "approved"
      }

      expect(response).to have_http_status(:ok)
      expect(payment.reload).to be_completed
      expect(order.reload).to be_processing
    end

    it "processes rejected payment webhook" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-456")

      post "/api/v1/webhooks/payment", params: {
        provider_payment_id: "SIM-456",
        status: "rejected"
      }

      expect(response).to have_http_status(:ok)
      expect(payment.reload).to be_failed
    end

    it "returns 200 for unknown payment (idempotent)" do
      post "/api/v1/webhooks/payment", params: {
        provider_payment_id: "UNKNOWN",
        status: "approved"
      }

      expect(response).to have_http_status(:ok)
    end

    it "returns 200 even on processing errors" do
      allow(PaymentService).to receive(:process_webhook!).and_raise(StandardError, "boom")

      post "/api/v1/webhooks/payment", params: {
        provider_payment_id: "SIM-123",
        status: "approved"
      }

      expect(response).to have_http_status(:ok)
    end
  end
end
