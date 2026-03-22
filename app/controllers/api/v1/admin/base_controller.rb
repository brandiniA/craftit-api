module Api
  module V1
    module Admin
      class BaseController < ::Api::V1::BaseController
        before_action :authenticate!
        before_action :authorize_admin!

        private

        def authorize_admin!
          admin_email = ENV.fetch("ADMIN_EMAIL", nil)
          if admin_email.blank? || current_auth_user_email != admin_email
            render_forbidden("Admin access required")
          end
        end
      end
    end
  end
end
