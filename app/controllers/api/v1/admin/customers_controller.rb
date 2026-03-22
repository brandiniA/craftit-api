module Api
  module V1
    module Admin
      class CustomersController < BaseController
        def index
          profiles = ::CustomerProfile.order(created_at: :desc)

          pagy, records = pagy(profiles)

          render_success(
            ::ProfileSerializer.new(records).serializable_hash[:data],
            meta: pagination_meta(pagy)
          )
        end

        def show
          profile = ::CustomerProfile.find(params[:id])

          render_success(::ProfileSerializer.new(profile).serializable_hash[:data])
        end
      end
    end
  end
end
