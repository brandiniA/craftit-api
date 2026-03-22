require "rails_helper"

RSpec.describe AutoApprovePaymentJob, type: :job do
  describe "#perform" do
    it "auto-approves pending payment after delay" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-123")
      product = create(:product)
      create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      described_class.perform_now(payment.id)

      expect(payment.reload).to be_completed
      expect(order.reload).to be_processing
    end

    it "does nothing if payment already completed" do
      order = create(:order, :paid)
      payment = create(:payment, :completed, order: order)

      expect do
        described_class.perform_now(payment.id)
      end.not_to change { payment.reload.status }
    end

    it "does nothing if payment does not exist" do
      expect do
        described_class.perform_now(999_999)
      end.not_to raise_error
    end
  end
end
