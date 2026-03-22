module Api
  module V1
    module Admin
      class ProductsController < BaseController
        def index
          products = ::Product.includes(:category, :images, :inventory)
            .order(created_at: :desc)

          pagy, records = pagy(products)

          render_success(
            ::ProductSerializer.new(records).serializable_hash[:data],
            meta: pagination_meta(pagy)
          )
        end

        def create
          product = ::Product.new(product_params)

          ActiveRecord::Base.transaction do
            product.save!
            initial_stock = params[:initial_stock]&.to_i || 0
            ::Inventory.create!(product: product, stock: initial_stock)
          end

          render_created(::ProductDetailSerializer.new(product.reload).serializable_hash[:data])
        rescue ActiveRecord::RecordInvalid => e
          render_validation_error(e.record)
        end

        def update
          product = ::Product.find(params[:id])

          if product.update(product_params)
            render_success(::ProductDetailSerializer.new(product).serializable_hash[:data])
          else
            render_validation_error(product)
          end
        end

        def destroy
          product = ::Product.find(params[:id])
          product.update!(is_active: false)

          render_success({ message: "Product deactivated" })
        end

        def images
          product = ::Product.find(params[:id])
          uploaded = params.require(:file)

          unless uploaded.content_type.to_s.start_with?("image/")
            return render_error(
              code: "validation_error",
              message: "File must be an image",
              status: :unprocessable_entity
            )
          end

          position = if params[:position].present?
            params[:position].to_i
          else
            product.images.maximum(:position).to_i + 1
          end

          image = product.images.build(alt_text: params[:alt_text], position: position)
          image.file.attach(uploaded)
          image.save!
          image.update!(
            url: rails_blob_url(
              image.file.blob,
              host: request.host_with_port,
              protocol: request.scheme
            )
          )

          render_created(
            {
              id: image.id,
              url: image.url,
              alt_text: image.alt_text,
              position: image.position
            }
          )
        rescue ActiveRecord::RecordInvalid => e
          render_validation_error(e.record)
        end

        private

        def product_params
          params.permit(:name, :description, :price, :compare_at_price,
            :sku, :category_id, :is_active, :is_featured)
        end
      end
    end
  end
end
