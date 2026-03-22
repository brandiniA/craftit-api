require "rails_helper"

RSpec.describe ReservationTimeoutJob, type: :job do
  describe "#perform" do
    it "cancels expired pending orders (older than 30 minutes)" do
      product = create(:product)
      inventory = create(:inventory, product: product, stock: 10, reserved_stock: 2)

      old_order = create(:order, :pending, created_at: 31.minutes.ago)
      create(:order_item, order: old_order, product: product, quantity: 2)

      recent_order = create(:order, :pending, created_at: 5.minutes.ago)

      described_class.perform_now

      expect(old_order.reload).to be_cancelled
      expect(recent_order.reload).to be_pending
      expect(inventory.reload.reserved_stock).to eq(0)
    end

    it "does not cancel paid orders" do
      paid_order = create(:order, :paid, created_at: 31.minutes.ago)

      described_class.perform_now

      expect(paid_order.reload).to be_paid
    end

    it "releases inventory for each cancelled order" do
      product1 = create(:product)
      product2 = create(:product)
      inventory1 = create(:inventory, product: product1, stock: 10, reserved_stock: 3)
      inventory2 = create(:inventory, product: product2, stock: 5, reserved_stock: 1)

      order = create(:order, :pending, created_at: 31.minutes.ago)
      create(:order_item, order: order, product: product1, quantity: 3)
      create(:order_item, order: order, product: product2, quantity: 1)

      described_class.perform_now

      expect(inventory1.reload.reserved_stock).to eq(0)
      expect(inventory2.reload.reserved_stock).to eq(0)
    end
  end
end
