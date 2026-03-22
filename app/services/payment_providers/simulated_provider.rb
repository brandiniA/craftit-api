module PaymentProviders
  # Simulated payment provider for development and testing.
  #
  # Features:
  # - Returns a fake payment URL (no external redirect)
  # - Generates provider_payment_id with SIM- prefix
  # - Supports manual approval via dev endpoint
  # - Supports auto-approval via background job (configurable delay)
  # - No signature verification (always returns true)
  #
  # Configuration:
  # - SIMULATED_PAYMENT_AUTO_APPROVE_DELAY (seconds, default: 30)
  #
  # Usage:
  #   Set PAYMENT_PROVIDER=simulated in .env
  class SimulatedProvider < BaseProvider
    PAYMENT_URL_BASE = "https://payments.craftitapp.local/pay".freeze

    def create_payment_intent!(order)
      provider_payment_id = generate_payment_id

      {
        payment_url: "#{PAYMENT_URL_BASE}/#{provider_payment_id}?order=#{order.order_number}",
        provider_payment_id: provider_payment_id
      }
    end

    def verify_webhook_signature(_payload, _signature)
      true
    end

    private

    def generate_payment_id
      "SIM-#{SecureRandom.hex(12)}"
    end
  end
end
