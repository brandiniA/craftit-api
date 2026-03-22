# Cancels pending orders older than 30 minutes and releases their inventory reservations.
# Designed to run periodically via cron/scheduler (e.g., every 10 minutes).
#
# Schedule with whenever gem or similar:
#   every 10.minutes do
#     runner "ReservationTimeoutJob.perform_later"
#   end
class ReservationTimeoutJob < ApplicationJob
  queue_as :default

  RESERVATION_TTL = 30.minutes

  def perform
    expired_orders = ::Order.pending.where("created_at < ?", RESERVATION_TTL.ago)

    expired_orders.find_each do |order|
      ActiveRecord::Base.transaction do
        order.order_items.includes(product: :inventory).each do |item|
          next unless item.product.inventory

          ::InventoryService.release!(item.product.inventory, item.quantity)
        end

        order.cancel!
      end

      Rails.logger.info("Cancelled expired order #{order.order_number}")
    rescue StandardError => e
      Rails.logger.error("Failed to cancel order #{order.order_number}: #{e.message}")
    end
  end
end
