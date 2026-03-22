module Api
  module V1
    class ProductsController < BaseController
      def index
        products = ::Product.active.includes(:category, :images, :inventory, :reviews)

        if params[:category].present?
          products = products.where(category: ::Category.friendly.find(params[:category]))
        end
        products = products.featured if params[:featured] == "true"

        pagy, records = pagy(products.order(created_at: :desc))

        render_success(
          ::ProductSerializer.new(records).serializable_hash[:data],
          meta: pagination_meta(pagy)
        )
      end

      def show
        product = ::Product.friendly.find(params[:slug])
        product = ::Product.includes(:category, :images, :inventory, :reviews).find(product.id)

        render_success(::ProductDetailSerializer.new(product).serializable_hash[:data])
      end

      def search
        products = ::Product.active.includes(:category, :images, :inventory, :reviews)

        if params[:q].present?
          products = products.where("name ILIKE ?", "%#{params[:q]}%")
        end

        if params[:min_price].present?
          products = products.where("price >= ?", params[:min_price])
        end

        if params[:max_price].present?
          products = products.where("price <= ?", params[:max_price])
        end

        if params[:category].present?
          products = products.where(category: ::Category.friendly.find(params[:category]))
        end

        pagy, records = pagy(products.order(created_at: :desc))

        render_success(
          ::ProductSerializer.new(records).serializable_hash[:data],
          meta: pagination_meta(pagy)
        )
      end
    end
  end
end
