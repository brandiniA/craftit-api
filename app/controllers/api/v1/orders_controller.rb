module Api
  module V1
    class OrdersController < BaseController
      before_action :authenticate!

      def index
        orders = current_customer_profile.orders
          .includes(:order_items)
          .order(created_at: :desc)

        pagy, records = pagy(orders)

        render_success(
          ::OrderSerializer.new(records).serializable_hash[:data],
          meta: pagination_meta(pagy)
        )
      end

      def show
        order = current_customer_profile.orders
          .includes(:order_items, :payment, :shipment)
          .find_by!(order_number: params[:order_number])

        render_success(::OrderDetailSerializer.new(order).serializable_hash[:data])
      end

      def create
        address = current_customer_profile.addresses.find(params[:address_id])

        order = OrderService.create_order!(
          customer_profile: current_customer_profile,
          address: address,
          customer_name: params[:customer_name],
          customer_email: params[:customer_email]
        )

        render_created(::OrderDetailSerializer.new(order).serializable_hash[:data])
      rescue OrderService::EmptyCartError => e
        render_error(code: "validation_error", message: e.message, status: :unprocessable_entity)
      rescue InventoryService::InsufficientStockError => e
        render_error(code: "insufficient_stock", message: e.message, status: :unprocessable_entity)
      end
    end
  end
end
