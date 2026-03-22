require "rails_helper"

RSpec.describe InventoryService do
  let(:product) { create(:product) }
  let(:inventory) { create(:inventory, product: product, stock: 10, reserved_stock: 0) }

  describe ".reserve!" do
    it "increments reserved_stock" do
      described_class.reserve!(inventory, 3)
      expect(inventory.reload.reserved_stock).to eq(3)
    end

    it "raises error when insufficient stock" do
      expect do
        described_class.reserve!(inventory, 15)
      end.to raise_error(InventoryService::InsufficientStockError)
    end
  end

  describe ".confirm!" do
    it "decrements both stock and reserved_stock" do
      inventory.update!(reserved_stock: 3)

      described_class.confirm!(inventory, 3)
      inventory.reload

      expect(inventory.stock).to eq(7)
      expect(inventory.reserved_stock).to eq(0)
    end
  end

  describe ".release!" do
    it "decrements reserved_stock" do
      inventory.update!(reserved_stock: 3)

      described_class.release!(inventory, 3)
      expect(inventory.reload.reserved_stock).to eq(0)
    end
  end
end
