require "rails_helper"

RSpec.describe PaymentProviders::SimulatedProvider do
  subject(:provider) { described_class.new }

  describe "#create_payment_intent!" do
    it "returns a simulated payment URL" do
      order = create(:order, total: 1500.00)

      result = provider.create_payment_intent!(order)

      expect(result[:payment_url]).to match(%r{^https://payments\.craftitapp\.local/pay/})
      expect(result[:provider_payment_id]).to match(/^SIM-/)
    end

    it "includes order_number in the URL" do
      order = create(:order, total: 1500.00)

      result = provider.create_payment_intent!(order)

      expect(result[:payment_url]).to include(order.order_number)
    end
  end

  describe "#verify_webhook_signature" do
    it "returns true for any payload in development/test" do
      expect(provider.verify_webhook_signature("payload", "signature")).to be true
    end
  end
end
