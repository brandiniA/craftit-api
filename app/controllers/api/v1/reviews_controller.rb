module Api
  module V1
    class ReviewsController < BaseController
      before_action :authenticate!, only: [ :create ]

      def index
        product = ::Product.friendly.find(params[:product_slug])
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

      def create
        product = ::Product.friendly.find(params[:product_slug])
        review = product.reviews.build(review_params)
        review.customer_profile = current_customer_profile

        if review.save
          render_created(::ReviewSerializer.new(review).serializable_hash[:data])
        else
          render_validation_error(review)
        end
      end

      private

      def review_params
        params.permit(:rating, :title, :body)
      end
    end
  end
end
