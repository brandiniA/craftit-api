module Api
  module V1
    class BaseController < ApplicationController
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
    end
  end
end
