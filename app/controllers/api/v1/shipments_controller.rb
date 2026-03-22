module Api
  module V1
    class ShipmentsController < BaseController
      before_action :authenticate!

      def show
        order = current_customer_profile.orders
          .find_by!(order_number: params[:order_number])

        shipment = order.shipment
        return render_not_found("No shipment found for this order") unless shipment

        render_success(::ShipmentSerializer.new(shipment).serializable_hash[:data])
      end
    end
  end
end
