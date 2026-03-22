require "rails_helper"

RSpec.describe OrderService do
  let(:profile) { create(:customer_profile, auth_user_id: "user-123") }
  let(:address) { create(:address, customer_profile: profile) }

  describe ".create_order!" do
    context "with valid cart and stock" do
      let(:profile) { create(:customer_profile, auth_user_id: "user-123") }
      let(:address) { create(:address, customer_profile: profile) }
      let(:figure_a) { create(:product, name: "Figure A", price: 500.00) }
      let(:figure_b) { create(:product, name: "Figure B", price: 300.00) }

      before do
        create(:inventory, product: figure_a, stock: 10)
        create(:inventory, product: figure_b, stock: 5)
        create(:cart_item, customer_profile: profile, product: figure_a, quantity: 2)
        create(:cart_item, customer_profile: profile, product: figure_b, quantity: 1)
      end

      it "creates an order with correct totals" do
        order = described_class.create_order!(
          customer_profile: profile,
          address: address,
          customer_name: "Test User",
          customer_email: "test@example.com"
        )

        aggregate_failures do
          expect(order).to be_pending
          expect(order.order_number).to match(/\ACRA-\d{8}-\d{4}\z/)
          expect(order.subtotal).to eq(1300.00) # 500*2 + 300*1
          expect(order.tax_rate_snapshot).to eq(0.16)
          expect(order.tax).to eq(208.00) # 1300 * 0.16
          expect(order.order_items.count).to eq(2)
        end
      end

      it "reserves stock for each item" do
        described_class.create_order!(
          customer_profile: profile,
          address: address,
          customer_name: "Test User",
          customer_email: "test@example.com"
        )

        expect(figure_a.inventory.reload.reserved_stock).to eq(2)
        expect(figure_b.inventory.reload.reserved_stock).to eq(1)
      end

      it "snapshots product prices and names" do
        order = described_class.create_order!(
          customer_profile: profile,
          address: address,
          customer_name: "Test User",
          customer_email: "test@example.com"
        )

        item = order.order_items.find_by(product: figure_a)
        expect(item.product_name_snapshot).to eq("Figure A")
        expect(item.price_snapshot).to eq(500.00)
      end

      it "clears the cart after order creation" do
        described_class.create_order!(
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
          described_class.create_order!(
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
          described_class.create_order!(
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
      number = described_class.generate_order_number
      expect(number).to match(/\ACRA-\d{8}-\d{4}\z/)
    end

    it "generates sequential numbers for same day" do
      n1 = described_class.generate_order_number
      create(:order, order_number: n1)
      n2 = described_class.generate_order_number

      seq1 = n1.split("-").last.to_i
      seq2 = n2.split("-").last.to_i
      expect(seq2).to be > seq1
    end
  end
end
