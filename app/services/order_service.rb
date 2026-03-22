class OrderService
  class EmptyCartError < StandardError; end

  TAX_RATE = BigDecimal("0.16")
  DEFAULT_SHIPPING_COST = BigDecimal("99.00")

  def self.create_order!(customer_profile:, address:, customer_name:, customer_email:)
    cart_items = customer_profile.cart_items.includes(product: :inventory)
    raise EmptyCartError, "Cart is empty" if cart_items.empty?

    ActiveRecord::Base.transaction do
      cart_items.each do |cart_item|
        inventory = cart_item.product.inventory
        raise InventoryService::InsufficientStockError, "#{cart_item.product.name} is out of stock" unless inventory

        InventoryService.reserve!(inventory, cart_item.quantity)
      end

      subtotal = cart_items.sum { |ci| ci.product.price * ci.quantity }
      tax = (subtotal * TAX_RATE).round(2)
      shipping_cost = DEFAULT_SHIPPING_COST
      total = subtotal + tax + shipping_cost

      order = Order.create!(
        customer_profile: customer_profile,
        order_number: generate_order_number,
        subtotal: subtotal,
        shipping_cost: shipping_cost,
        tax: tax,
        tax_rate_snapshot: TAX_RATE,
        total: total,
        customer_name_snapshot: customer_name,
        customer_email_snapshot: customer_email,
        shipping_address_snapshot: {
          label: address.label,
          street: address.street,
          city: address.city,
          state: address.state,
          zip_code: address.zip_code,
          country: address.country
        }
      )

      cart_items.each do |cart_item|
        order.order_items.create!(
          product: cart_item.product,
          product_name_snapshot: cart_item.product.name,
          price_snapshot: cart_item.product.price,
          quantity: cart_item.quantity
        )
      end

      customer_profile.cart_items.destroy_all

      order
    end
  end

  def self.generate_order_number
    date = Date.current.strftime("%Y%m%d")
    prefix = "CRA-#{date}-"
    today_count = Order.where("order_number LIKE ?", "#{prefix}%").count
    sequence = format("%04d", today_count + 1)
    "#{prefix}#{sequence}"
  end
end
