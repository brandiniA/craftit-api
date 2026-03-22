module Api
  module V1
    module Admin
      class DashboardController < BaseController
        def stats
          render_success(
            {
              total_products: ::Product.count,
              active_products: ::Product.active.count,
              total_orders: ::Order.count,
              pending_orders: ::Order.pending.count,
              processing_orders: ::Order.processing.count,
              total_revenue: ::Order.where(status: [ :paid, :processing, :shipped, :delivered ]).sum(:total),
              total_customers: ::CustomerProfile.count,
              low_stock_count: ::Inventory.low_stock.count
            }
          )
        end
      end
    end
  end
end
