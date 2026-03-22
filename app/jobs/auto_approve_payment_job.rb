# Auto-approves simulated payments after configured delay.
# Only processes payments still in pending state.
class AutoApprovePaymentJob < ApplicationJob
  queue_as :default

  def perform(payment_id)
    payment = ::Payment.find_by(id: payment_id)
    return unless payment
    return unless payment.pending?

    Rails.logger.info("Auto-approving simulated payment #{payment.provider_payment_id}")

    ::PaymentService.process_webhook!(
      provider_payment_id: payment.provider_payment_id,
      status: "approved"
    )
  end
end
