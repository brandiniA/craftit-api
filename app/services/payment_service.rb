# PaymentService - Provider-agnostic payment processing
#
# Architecture: Strategy pattern with pluggable payment providers
#
# Current provider: SimulatedProvider (default)
# Supported providers: Simulated (add MercadoPago, Stripe, etc. as needed)
#
# To add a new provider:
# 1. Create app/services/payment_providers/my_provider.rb inheriting from BaseProvider
# 2. Implement create_payment_intent! and verify_webhook_signature
# 3. Set ENV PAYMENT_PROVIDER=my_provider
#
# Example MercadoPago integration:
#   class MercadopagoProvider < PaymentProviders::BaseProvider
#     def create_payment_intent!(order)
#       sdk = MercadoPago::SDK.new(ENV['MERCADOPAGO_ACCESS_TOKEN'])
#       preference = sdk.preference.create(...)
#       { payment_url: preference.init_point, provider_payment_id: preference.id }
#     end
#
#     def verify_webhook_signature(payload, signature)
#       # MercadoPago signature verification logic
#     end
#   end
#
# Simulated provider features:
# - Auto-approval after 30 seconds (configurable via SIMULATED_PAYMENT_AUTO_APPROVE_DELAY)
# - Manual approval via POST /api/v1/dev/simulated_payments/:id/approve (dev-only)
# - Manual rejection via POST /api/v1/dev/simulated_payments/:id/reject (dev-only)
class PaymentService
  AUTO_APPROVE_DELAY = ENV.fetch("SIMULATED_PAYMENT_AUTO_APPROVE_DELAY", "30").to_i.seconds

  class << self
    # Creates a payment and initiates payment intent with the active provider
    #
    # @param order [Order]
    # @return [Hash] { payment_url: String, payment: Payment }
    def create_payment!(order)
      provider_result = payment_provider.create_payment_intent!(order)

      payment = order.create_payment!(
        provider: provider_name,
        provider_payment_id: provider_result[:provider_payment_id],
        amount: order.total,
        currency: "MXN"
      )

      if provider_name == "simulated"
        ::AutoApprovePaymentJob.set(wait: AUTO_APPROVE_DELAY).perform_later(payment.id)
      end

      {
        payment_url: provider_result[:payment_url],
        payment: payment
      }
    end

    # Processes webhook notification from payment provider
    #
    # @param provider_payment_id [String]
    # @param status [String] "approved", "rejected", "cancelled"
    def process_webhook!(provider_payment_id:, status:)
      payment = ::Payment.find_by(provider_payment_id: provider_payment_id)
      return unless payment

      order = payment.order

      ActiveRecord::Base.transaction do
        case status
        when "approved"
          payment.complete!
          order.pay! if order.may_pay?
          order.process! if order.may_process?

          order.order_items.includes(product: :inventory).each do |item|
            ::InventoryService.confirm!(item.product.inventory, item.quantity)
          end
        when "rejected", "cancelled"
          payment.fail_payment!
        end
      end

      payment
    end

    private

    def payment_provider
      @payment_provider ||= begin
        provider_class_name = "PaymentProviders::#{provider_name.camelize}Provider"
        provider_class_name.constantize.new
      rescue NameError
        raise "Payment provider '#{provider_name}' not found. Check PAYMENT_PROVIDER env var."
      end
    end

    def provider_name
      ENV.fetch("PAYMENT_PROVIDER", "simulated")
    end
  end
end
