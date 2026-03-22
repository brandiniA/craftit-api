class OrderSerializer
  include JSONAPI::Serializer

  attributes :order_number, :status, :subtotal, :shipping_cost,
    :tax, :total, :created_at

  attribute :item_count do |order|
    order.order_items.size
  end
end
