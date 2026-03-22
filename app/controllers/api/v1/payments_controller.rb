module Api
  module V1
    class PaymentsController < BaseController
      before_action :authenticate!

      def create
        order = current_customer_profile.orders
          .find_by!(order_number: params[:order_number])

        if order.payment.present?
          return render_error(
            code: "payment_already_exists",
            message: "Payment already exists for this order",
            status: :unprocessable_entity
          )
        end

        result = ::PaymentService.create_payment!(order)

        render_created({
          payment_id: result[:payment].id,
          payment_url: result[:payment_url],
          amount: result[:payment].amount.to_s,
          currency: result[:payment].currency
        })
      end
    end
  end
end
