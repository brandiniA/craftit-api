require "rails_helper"

RSpec.describe PaymentService do
  describe ".create_payment!" do
    it "creates a pending payment record" do
      order = create(:order, total: 1500.00)

      payment = described_class.create_payment!(order)[:payment]

      expect(payment).to be_pending
      expect(payment.provider).to eq("simulated")
      expect(payment.amount).to eq(1500.00)
      expect(payment.currency).to eq("MXN")
      expect(payment.provider_payment_id).to be_present
    end

    it "returns payment_url from provider" do
      order = create(:order, total: 1500.00)

      result = described_class.create_payment!(order)

      expect(result[:payment_url]).to be_present
      expect(result[:payment_url]).to match(/payments\.craftitapp\.local/)
    end

    it "schedules auto-approval job" do
      order = create(:order, total: 1500.00)

      expect do
        described_class.create_payment!(order)
      end.to have_enqueued_job(AutoApprovePaymentJob)
    end
  end

  describe ".process_webhook!" do
    it "completes payment and transitions order to processing" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-123")
      product = create(:product)
      create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      described_class.process_webhook!(
        provider_payment_id: "SIM-123",
        status: "approved"
      )

      expect(payment.reload).to be_completed
      expect(order.reload).to be_processing
    end

    it "confirms inventory (deducts reserved stock and stock)" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-123")
      product = create(:product)
      inventory = create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      described_class.process_webhook!(
        provider_payment_id: "SIM-123",
        status: "approved"
      )

      expect(inventory.reload.stock).to eq(8)
      expect(inventory.reload.reserved_stock).to eq(0)
    end

    it "marks payment as failed for rejected status" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-123")

      described_class.process_webhook!(
        provider_payment_id: "SIM-123",
        status: "rejected"
      )

      expect(payment.reload).to be_failed
      expect(order.reload).to be_pending
    end

    it "returns nil for unknown provider_payment_id" do
      result = described_class.process_webhook!(
        provider_payment_id: "UNKNOWN",
        status: "approved"
      )

      expect(result).to be_nil
    end
  end
end
