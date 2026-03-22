module Api
  module V1
    class BaseController < ApplicationController
      include Pagy::Backend

      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
      rescue_from ActionController::ParameterMissing, with: :handle_bad_request

      private

      def handle_not_found(exception)
        render_not_found(exception.message)
      end

      def handle_record_invalid(exception)
        render_validation_error(exception.record)
      end

      def handle_bad_request(exception)
        render_error(
          code: "bad_request",
          message: exception.message,
          status: :bad_request
        )
      end

      def current_auth_user_id
        request.env["auth_user_id"]
      end

      def current_customer_profile
        return nil unless current_auth_user_id

        @current_customer_profile ||= ::CustomerProfile.find_or_create_by!(
          auth_user_id: current_auth_user_id
        )
      end

      def authenticate!
        render_unauthorized unless current_auth_user_id
      end

      def pagination_meta(pagy)
        {
          page: pagy.page,
          limit: pagy.limit,
          total_pages: pagy.pages,
          total_count: pagy.count
        }
      end
    end
  end
end
