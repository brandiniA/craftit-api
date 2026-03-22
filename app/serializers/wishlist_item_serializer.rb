class WishlistItemSerializer
  include JSONAPI::Serializer

  attributes :created_at

  attribute :product do |wishlist_item|
    product = wishlist_item.product
    {
      id: product.id,
      name: product.name,
      slug: product.slug,
      price: product.price,
      compare_at_price: product.compare_at_price,
      primary_image_url: product.images.ordered.first&.url,
      in_stock: product.in_stock?,
      on_sale: product.on_sale?
    }
  end
end
