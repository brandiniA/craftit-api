require "rails_helper"

RSpec.describe Shipment, type: :model do
  describe "AASM state machine" do
    subject { create(:shipment) }

    it "starts as preparing" do
      expect(subject).to be_preparing
    end

    it "transitions to shipped" do
      subject.ship!
      expect(subject).to be_shipped
    end

    it "transitions to in_transit" do
      subject.ship!
      subject.in_transit!
      expect(subject).to be_in_transit
    end

    it "transitions to delivered" do
      subject.ship!
      subject.in_transit!
      subject.deliver!
      expect(subject).to be_delivered
    end
  end
end
