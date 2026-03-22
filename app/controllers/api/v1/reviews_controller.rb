module Api
  module V1
    class ReviewsController < BaseController
      def index
        product = ::Product.friendly.find(params[:slug])
        reviews = product.reviews.includes(:customer_profile)
          .order(created_at: :desc)

        pagy, records = pagy(reviews)

        avg = product.reviews.average(:rating)
        average_rating = avg.nil? ? nil : avg.to_f.round(1)

        render_success(
          ::ReviewSerializer.new(records).serializable_hash[:data],
          meta: pagination_meta(pagy).merge(
            average_rating: average_rating,
            total_count: product.reviews.count
          )
        )
      end
    end
  end
end
