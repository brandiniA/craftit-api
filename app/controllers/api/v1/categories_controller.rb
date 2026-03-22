module Api
  module V1
    class CategoriesController < BaseController
      def index
        categories = ::Category.includes(:parent_category, :subcategories, :products)
          .ordered

        render_success(::CategorySerializer.new(categories).serializable_hash[:data])
      end

      def show
        category = ::Category.friendly.find(params[:slug])
        products = category.products.active
          .includes(:images, :inventory, :reviews)
          .order(created_at: :desc)

        pagy, records = pagy(products)

        render_success(
          {
            category: ::CategorySerializer.new(category).serializable_hash[:data],
            products: ::ProductSerializer.new(records).serializable_hash[:data]
          },
          meta: pagination_meta(pagy)
        )
      end
    end
  end
end
