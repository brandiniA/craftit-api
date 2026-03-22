module PaymentProviders
  # Abstract base class defining the interface all payment providers must implement.
  # Consumers use PaymentService, which delegates to the active provider.
  #
  # To add a new provider:
  # 1. Create a class inheriting from BaseProvider
  # 2. Implement create_payment_intent! and verify_webhook_signature
  # 3. Set PAYMENT_PROVIDER env var to the class name
  #
  # Example:
  #   class MercadopagoProvider < BaseProvider
  #     def create_payment_intent!(order)
  #       # ... MercadoPago SDK logic
  #     end
  #   end
  class BaseProvider
    class NotImplementedError < StandardError; end
    class PaymentError < StandardError; end

    # Creates a payment intent with the provider and returns payment URL + metadata
    #
    # @param order [Order] The order to create payment for
    # @return [Hash] { payment_url: String, provider_payment_id: String }
    # @raise [PaymentError] if payment creation fails
    def create_payment_intent!(order)
      raise NotImplementedError, "#{self.class} must implement create_payment_intent!"
    end

    # Verifies webhook signature from the payment provider
    #
    # @param payload [String] Raw request body
    # @param signature [String] Signature header from the provider
    # @return [Boolean] true if signature is valid
    def verify_webhook_signature(payload, signature)
      raise NotImplementedError, "#{self.class} must implement verify_webhook_signature"
    end
  end
end
