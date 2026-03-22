require "rails_helper"

RSpec.describe Order, type: :model do
  describe "validations" do
    subject { build(:order) }

    it { is_expected.to be_valid }

    it "requires order_number" do
      subject.order_number = nil
      expect(subject).not_to be_valid
    end

    it "requires unique order_number" do
      create(:order, order_number: "CRA-20260322-0001")
      subject.order_number = "CRA-20260322-0001"
      expect(subject).not_to be_valid
    end

    it "requires subtotal" do
      subject.subtotal = nil
      expect(subject).not_to be_valid
    end

    it "requires total" do
      subject.total = nil
      expect(subject).not_to be_valid
    end
  end

  describe "AASM state machine" do
    subject { create(:order) }

    it "starts as pending" do
      expect(subject).to be_pending
    end

    it "transitions from pending to paid" do
      subject.pay!
      expect(subject).to be_paid
    end

    it "transitions from paid to processing" do
      subject.pay!
      subject.process!
      expect(subject).to be_processing
    end

    it "transitions from processing to shipped" do
      subject.pay!
      subject.process!
      subject.ship!
      expect(subject).to be_shipped
    end

    it "transitions from shipped to delivered" do
      subject.pay!
      subject.process!
      subject.ship!
      subject.deliver!
      expect(subject).to be_delivered
    end

    it "can cancel from pending" do
      subject.cancel!
      expect(subject).to be_cancelled
    end

    it "can cancel from paid" do
      subject.pay!
      subject.cancel!
      expect(subject).to be_cancelled
    end

    it "cannot cancel from delivered" do
      subject.pay!
      subject.process!
      subject.ship!
      subject.deliver!
      expect { subject.cancel! }.to raise_error(AASM::InvalidTransition)
    end
  end

  describe "associations" do
    it "has many order_items" do
      order = create(:order)
      item = create(:order_item, order: order)
      expect(order.order_items).to include(item)
    end
  end
end
