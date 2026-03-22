module Api
  module V1
    module Dev
      # Development-only endpoint for manually approving/rejecting simulated payments.
      # Disabled in production.
      #
      # Usage (from Postman or curl):
      #   POST /api/v1/dev/simulated_payments/SIM-abc123/approve
      #   POST /api/v1/dev/simulated_payments/SIM-abc123/reject
      class SimulatedPaymentsController < BaseController
        before_action :ensure_development_mode

        def approve
          payment = ::Payment.find_by!(provider_payment_id: params[:provider_payment_id])

          ::PaymentService.process_webhook!(
            provider_payment_id: payment.provider_payment_id,
            status: "approved"
          )

          render_success({ message: "Payment approved", payment_id: payment.id })
        end

        def reject
          payment = ::Payment.find_by!(provider_payment_id: params[:provider_payment_id])

          ::PaymentService.process_webhook!(
            provider_payment_id: payment.provider_payment_id,
            status: "rejected"
          )

          render_success({ message: "Payment rejected", payment_id: payment.id })
        end

        private

        def ensure_development_mode
          return if Rails.env.development? || Rails.env.test?

          render_error(
            code: "forbidden",
            message: "Dev endpoints are only available in development/test",
            status: :forbidden
          )
        end
      end
    end
  end
end
