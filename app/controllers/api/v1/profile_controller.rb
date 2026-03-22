module Api
  module V1
    class ProfileController < BaseController
      before_action :authenticate!

      def show
        render_success(::ProfileSerializer.new(current_customer_profile).serializable_hash[:data])
      end

      def update
        if current_customer_profile.update(profile_params)
          render_success(::ProfileSerializer.new(current_customer_profile).serializable_hash[:data])
        else
          render_validation_error(current_customer_profile)
        end
      end

      private

      def profile_params
        params.permit(:phone, :birth_date)
      end
    end
  end
end
