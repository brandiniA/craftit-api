module Api
  module V1
    class AddressesController < BaseController
      before_action :authenticate!

      def index
        addresses = current_customer_profile.addresses.order(created_at: :desc)

        render_success(::AddressSerializer.new(addresses).serializable_hash[:data])
      end

      def create
        address = current_customer_profile.addresses.build(address_params)

        if address.save
          render_created(::AddressSerializer.new(address).serializable_hash[:data])
        else
          render_validation_error(address)
        end
      end

      def update
        address = current_customer_profile.addresses.find(params[:id])

        if address.update(address_params)
          render_success(::AddressSerializer.new(address).serializable_hash[:data])
        else
          render_validation_error(address)
        end
      end

      def destroy
        address = current_customer_profile.addresses.find(params[:id])
        address.destroy!

        render_success({ message: "Address deleted" })
      end

      private

      def address_params
        params.permit(:label, :street, :city, :state, :zip_code, :country, :is_default)
      end
    end
  end
end
