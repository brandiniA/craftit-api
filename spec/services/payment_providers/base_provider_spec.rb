require "rails_helper"

RSpec.describe PaymentProviders::BaseProvider do
  subject(:provider) { described_class.new }

  describe "#create_payment_intent!" do
    it "raises NotImplementedError" do
      order = build(:order)
      expect do
        provider.create_payment_intent!(order)
      end.to raise_error(PaymentProviders::BaseProvider::NotImplementedError)
    end
  end

  describe "#verify_webhook_signature" do
    it "raises NotImplementedError" do
      expect do
        provider.verify_webhook_signature("payload", "signature")
      end.to raise_error(PaymentProviders::BaseProvider::NotImplementedError)
    end
  end
end
