module Api
  module V1
    module Admin
      class InventoryController < BaseController
        def index
          inventories = ::Inventory.includes(:product)
            .order(:id)

          pagy, records = pagy(inventories)

          render_success(
            records.map { |inv| inventory_json(inv) },
            meta: pagination_meta(pagy)
          )
        end

        def low_stock
          inventories = ::Inventory.low_stock.includes(:product)

          render_success(inventories.map { |inv| inventory_json(inv) })
        end

        def update
          inventory = ::Inventory.find_by!(product_id: params[:id])

          if inventory.update(inventory_params)
            render_success(inventory_json(inventory))
          else
            render_validation_error(inventory)
          end
        end

        private

        def inventory_params
          params.permit(:stock, :low_stock_threshold)
        end

        def inventory_json(inventory)
          {
            product_id: inventory.product_id,
            product_name: inventory.product.name,
            product_sku: inventory.product.sku,
            stock: inventory.stock,
            reserved_stock: inventory.reserved_stock,
            available_stock: inventory.available_stock,
            low_stock_threshold: inventory.low_stock_threshold,
            low_stock: inventory.low_stock?
          }
        end
      end
    end
  end
end
