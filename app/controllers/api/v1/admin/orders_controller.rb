module Api
  module V1
    module Admin
      class OrdersController < BaseController
        def index
          orders = ::Order.includes(:customer_profile, :order_items)
            .order(created_at: :desc)

          orders = orders.where(status: params[:status]) if params[:status].present?

          pagy, records = pagy(orders)

          render_success(
            ::OrderSerializer.new(records).serializable_hash[:data],
            meta: pagination_meta(pagy)
          )
        end

        def status
          order = ::Order.find(params[:id])

          event = status_event(params[:status])
          unless event && order.send(:"may_#{event}?")
            return render_error(
              code: "validation_error",
              message: "Cannot transition to #{params[:status]}",
              status: :unprocessable_entity
            )
          end

          order.send(:"#{event}!")
          render_success(::OrderDetailSerializer.new(order.reload).serializable_hash[:data])
        end

        def shipment
          order = ::Order.find(params[:id])

          ActiveRecord::Base.transaction do
            order.create_shipment!(shipment_params)
            order.ship! if order.may_ship?
          end

          render_created(::ShipmentSerializer.new(order.shipment.reload).serializable_hash[:data])
        rescue ActiveRecord::RecordInvalid => e
          render_validation_error(e.record)
        end

        private

        def shipment_params
          p = params.permit(:carrier, :tracking_number, :tracking_url, :estimated_delivery)
          p[:estimated_delivery] = p[:estimated_delivery].to_date if p[:estimated_delivery].present?
          p
        end

        def status_event(target_status)
          {
            "paid" => "pay",
            "processing" => "process",
            "shipped" => "ship",
            "delivered" => "deliver",
            "cancelled" => "cancel"
          }[target_status]
        end
      end
    end
  end
end
