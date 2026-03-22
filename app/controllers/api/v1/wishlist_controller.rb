module Api
  module V1
    class WishlistController < BaseController
      before_action :authenticate!

      def show
        items = current_customer_profile.wishlist_items
          .includes(product: [ :images, :inventory ])
          .order(created_at: :desc)

        render_success(::WishlistItemSerializer.new(items).serializable_hash[:data])
      end

      def create
        item = current_customer_profile.wishlist_items.build(
          product_id: params[:product_id]
        )

        if item.save
          render_created(::WishlistItemSerializer.new(item).serializable_hash[:data])
        elsif item.errors[:product_id]&.include?("has already been taken")
          render_error(
            code: "already_exists",
            message: "Product is already in your wishlist",
            status: :conflict
          )
        else
          render_validation_error(item)
        end
      end

      def destroy
        item = current_customer_profile.wishlist_items.find(params[:id])
        item.destroy!

        render_success({ message: "Item removed from wishlist" })
      end
    end
  end
end
