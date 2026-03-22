module Api
  module V1
    class CartController < BaseController
      before_action :authenticate!

      def show
        items = current_customer_profile.cart_items
          .includes(product: [ :images, :inventory ])

        render_success(::CartItemSerializer.new(items).serializable_hash[:data])
      end

      def create
        item = current_customer_profile.cart_items
          .find_by(product_id: params[:product_id])

        if item
          item.quantity += params[:quantity].to_i
          if item.save
            render_success(::CartItemSerializer.new(item).serializable_hash[:data])
          else
            render_validation_error(item)
          end
        else
          item = current_customer_profile.cart_items.build(
            product_id: params[:product_id],
            quantity: params[:quantity]
          )
          if item.save
            render_created(::CartItemSerializer.new(item).serializable_hash[:data])
          else
            render_validation_error(item)
          end
        end
      end

      def update
        item = current_customer_profile.cart_items.find(params[:id])

        if item.update(quantity: params[:quantity])
          render_success(::CartItemSerializer.new(item).serializable_hash[:data])
        else
          render_validation_error(item)
        end
      end

      def destroy
        item = current_customer_profile.cart_items.find(params[:id])
        item.destroy!

        render_success({ message: "Item removed from cart" })
      end

      def sync
        items_params = params.permit(items: [ :product_id, :quantity ])[:items] || []

        items_params.each do |item_data|
          product_id = item_data[:product_id] || item_data["product_id"]
          quantity = (item_data[:quantity] || item_data["quantity"]).to_i

          existing = current_customer_profile.cart_items
            .find_by(product_id: product_id)

          if existing
            existing.update!(quantity: existing.quantity + quantity)
          else
            current_customer_profile.cart_items.create!(
              product_id: product_id,
              quantity: quantity
            )
          end
        end

        items = current_customer_profile.cart_items
          .includes(product: [ :images, :inventory ])

        render_success(::CartItemSerializer.new(items).serializable_hash[:data])
      end
    end
  end
end
