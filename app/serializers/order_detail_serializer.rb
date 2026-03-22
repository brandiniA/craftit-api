class OrderDetailSerializer
  include JSONAPI::Serializer

  attributes :order_number, :status, :subtotal, :shipping_cost,
    :tax, :tax_rate_snapshot, :total,
    :customer_name_snapshot, :customer_email_snapshot,
    :shipping_address_snapshot, :created_at

  attribute :items do |order|
    order.order_items.map do |item|
      {
        id: item.id,
        product_id: item.product_id,
        product_name: item.product_name_snapshot,
        price: item.price_snapshot,
        quantity: item.quantity,
        subtotal: item.subtotal
      }
    end
  end

  attribute :payment do |order|
    payment = order.payment
    if payment
      { status: payment.status, provider: payment.provider, amount: payment.amount }
    end
  end

  attribute :shipment do |order|
    shipment = order.shipment
    if shipment
      {
        status: shipment.status,
        carrier: shipment.carrier,
        tracking_number: shipment.tracking_number,
        tracking_url: shipment.tracking_url,
        estimated_delivery: shipment.estimated_delivery
      }
    end
  end
end
