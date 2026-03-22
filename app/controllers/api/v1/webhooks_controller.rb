module Api
  module V1
    class WebhooksController < BaseController
      def payment
        # TODO: Verify webhook signature when using real provider
        # provider = PaymentService.send(:payment_provider)
        # unless provider.verify_webhook_signature(request.raw_post, request.headers["X-Signature"])
        #   return head :unauthorized
        # end

        ::PaymentService.process_webhook!(
          provider_payment_id: params[:provider_payment_id],
          status: params[:status]
        )

        head :ok
      rescue StandardError => e
        Rails.logger.error("Webhook processing error: #{e.message}")
        head :ok
      end
    end
  end
end
