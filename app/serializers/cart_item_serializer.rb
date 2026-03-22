class CartItemSerializer
  include JSONAPI::Serializer

  attributes :quantity, :created_at

  attribute :product do |cart_item|
    product = cart_item.product
    {
      id: product.id,
      name: product.name,
      slug: product.slug,
      price: product.price,
      primary_image_url: product.images.ordered.first&.url,
      in_stock: product.in_stock?,
      available_stock: product.available_stock
    }
  end

  attribute :subtotal do |cart_item|
    cart_item.subtotal
  end
end
