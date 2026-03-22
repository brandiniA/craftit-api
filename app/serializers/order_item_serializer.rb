class OrderItemSerializer
  include JSONAPI::Serializer

  attributes :product_name_snapshot, :price_snapshot, :quantity

  attribute :subtotal do |item|
    item.subtotal
  end

  attribute :product_slug do |item|
    item.product&.slug
  end
end
