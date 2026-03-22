require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "validations" do
    subject { build(:payment) }

    it { is_expected.to be_valid }

    it "requires provider" do
      subject.provider = nil
      expect(subject).not_to be_valid
    end

    it "requires amount" do
      subject.amount = nil
      expect(subject).not_to be_valid
    end

    it "requires positive amount" do
      subject.amount = 0
      expect(subject).not_to be_valid
    end
  end

  describe "AASM state machine" do
    subject { create(:payment) }

    it "starts as pending" do
      expect(subject).to be_pending
    end

    it "transitions to completed" do
      subject.complete!
      expect(subject).to be_completed
    end

    it "transitions to failed" do
      subject.fail_payment!
      expect(subject).to be_failed
    end

    it "transitions from completed to refunded" do
      subject.complete!
      subject.refund!
      expect(subject).to be_refunded
    end
  end
end
