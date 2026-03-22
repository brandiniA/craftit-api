require "rails_helper"

RSpec.describe Inventory, type: :model do
  describe "validations" do
    subject { build(:inventory) }

    it { is_expected.to be_valid }

    it "requires stock to be non-negative" do
      subject.stock = -1
      expect(subject).not_to be_valid
    end

    it "requires reserved_stock to be non-negative" do
      subject.reserved_stock = -1
      expect(subject).not_to be_valid
    end

    it "requires low_stock_threshold to be non-negative" do
      subject.low_stock_threshold = -1
      expect(subject).not_to be_valid
    end
  end

  describe "#available_stock" do
    it "returns stock minus reserved_stock" do
      inventory = build(:inventory, stock: 10, reserved_stock: 3)
      expect(inventory.available_stock).to eq(7)
    end
  end

  describe "#in_stock?" do
    it "returns true when available stock is positive" do
      inventory = build(:inventory, stock: 5, reserved_stock: 0)
      expect(inventory).to be_in_stock
    end

    it "returns false when all stock is reserved" do
      inventory = build(:inventory, stock: 5, reserved_stock: 5)
      expect(inventory).not_to be_in_stock
    end
  end

  describe "#low_stock?" do
    it "returns true when available stock is at or below threshold" do
      inventory = build(:inventory, stock: 5, reserved_stock: 0, low_stock_threshold: 5)
      expect(inventory).to be_low_stock
    end

    it "returns false when available stock is above threshold" do
      inventory = build(:inventory, stock: 10, reserved_stock: 0, low_stock_threshold: 5)
      expect(inventory).not_to be_low_stock
    end
  end

  describe "#sufficient_stock?" do
    it "returns true when enough available stock for quantity" do
      inventory = build(:inventory, stock: 10, reserved_stock: 3)
      expect(inventory.sufficient_stock?(5)).to be true
    end

    it "returns false when not enough available stock" do
      inventory = build(:inventory, stock: 10, reserved_stock: 8)
      expect(inventory.sufficient_stock?(5)).to be false
    end
  end
end
