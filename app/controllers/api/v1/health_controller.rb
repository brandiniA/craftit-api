module Api
  module V1
    class HealthController < BaseController
      def show
        render_success({ status: "ok" })
      end
    end
  end
end
