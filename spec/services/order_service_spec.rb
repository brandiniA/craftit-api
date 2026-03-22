require "rails_helper"

RSpec.describe OrderService do
  let(:profile) { create(:customer_profile, auth_user_id: "user-123") }
  let(:address) { create(:address, customer_profile: profile) }

  describe ".create_order!" do
    context "with valid cart and stock" do
      let!(:product1) { create(:product, name: "Figure A", price: 500.00) }
      let!(:product2) { create(:product, name: "Figure B", price: 300.00) }
      let!(:inv1) { create(:inventory, product: product1, stock: 10) }
      let!(:inv2) { create(:inventory, product: product2, stock: 5) }
      let!(:cart_item1) { create(:cart_item, customer_profile: profile, product: product1, quantity: 2) }
      let!(:cart_item2) { create(:cart_item, customer_profile: profile, product: product2, quantity: 1) }

      it "creates an order with correct totals" do
        order = OrderService.create_order!(
          customer_profile: profile,
          address: address,
          customer_name: "Test User",
          customer_email: "test@example.com"
        )

        expect(order).to be_pending
        expect(order.order_number).to match(/\ACRA-\d{8}-\d{4}\z/)
        expect(order.subtotal).to eq(1300.00) # 500*2 + 300*1
        expect(order.tax_rate_snapshot).to eq(0.16)
        expect(order.tax).to eq(208.00) # 1300 * 0.16
        expect(order.order_items.count).to eq(2)
      end

      it "reserves stock for each item" do
        OrderService.create_order!(
          customer_profile: profile,
          address: address,
          customer_name: "Test User",
          customer_email: "test@example.com"
        )

        expect(inv1.reload.reserved_stock).to eq(2)
        expect(inv2.reload.reserved_stock).to eq(1)
      end

      it "snapshots product prices and names" do
        order = OrderService.create_order!(
          customer_profile: profile,
          address: address,
          customer_name: "Test User",
          customer_email: "test@example.com"
        )

        item = order.order_items.find_by(product: product1)
        expect(item.product_name_snapshot).to eq("Figure A")
        expect(item.price_snapshot).to eq(500.00)
      end

      it "clears the cart after order creation" do
        OrderService.create_order!(
          customer_profile: profile,
          address: address,
          customer_name: "Test User",
          customer_email: "test@example.com"
        )

        expect(profile.cart_items.count).to eq(0)
      end
    end

    context "with insufficient stock" do
      it "raises error and does not create order" do
        product = create(:product, price: 100)
        create(:inventory, product: product, stock: 1)
        create(:cart_item, customer_profile: profile, product: product, quantity: 5)

        expect do
          OrderService.create_order!(
            customer_profile: profile,
            address: address,
            customer_name: "Test",
            customer_email: "test@example.com"
          )
        end.to raise_error(InventoryService::InsufficientStockError)

        expect(Order.count).to eq(0)
      end
    end

    context "with empty cart" do
      it "raises error" do
        expect do
          OrderService.create_order!(
            customer_profile: profile,
            address: address,
            customer_name: "Test",
            customer_email: "test@example.com"
          )
        end.to raise_error(OrderService::EmptyCartError)
      end
    end
  end

  describe ".generate_order_number" do
    it "generates order number in CRA-YYYYMMDD-XXXX format" do
      number = OrderService.generate_order_number
      expect(number).to match(/\ACRA-\d{8}-\d{4}\z/)
    end

    it "generates sequential numbers for same day" do
      n1 = OrderService.generate_order_number
      create(:order, order_number: n1)
      n2 = OrderService.generate_order_number

      seq1 = n1.split("-").last.to_i
      seq2 = n2.split("-").last.to_i
      expect(seq2).to be > seq1
    end
  end
end
