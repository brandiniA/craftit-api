# Module 4B: Authenticated API — Orders & Services Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Orders API (create, list, detail), Review creation, Shipment viewing, and the core services (OrderService, InventoryService) that encapsulate checkout business logic.

**Architecture:** Controllers are thin — `OrderService` handles the checkout flow (stock validation, reservation, tax calculation, order number generation, snapshots). `InventoryService` manages stock reservation and confirmation. Services are plain Ruby objects in `app/services/`.

**Tech Stack:** Rails 8.1, AASM, RSpec, FactoryBot

**Spec reference:** `craftitapp/docs/superpowers/specs/2026-03-21-backend-architecture-design.md` — Core Flows > Checkout

**Depends on:** Modules 1, 2A, 2B, 3, and 4A must be completed first.

---

## Implementation notes (reference)

These details match the `feature/implementation-plans` implementation. Earlier snippets in this document may still show draft code; treat this section as the source of truth for routing and parameters.

### Routes and parameters

| Topic | Pitfall | Actual choice |
|--------|---------|----------------|
| **Shipment under orders** | Nesting `resource :shipment` under `resources :orders, param: :order_number` makes Rails use a param like `order_order_number` for the parent segment. | Use a **member** route: `get "shipment", to: "shipments#show", on: :member` inside `resources :orders, …`. URL: `GET /api/v1/orders/:order_number/shipment`. In `ShipmentsController`, use **`params[:order_number]`** (not `params[:id]`). |
| **Reviews under products** | Assuming the nested param is still named `slug`. | With `resources :reviews` nested under `resources :products, param: :slug`, the path is still `/api/v1/products/<slug>/reviews`, but the **request param key** is **`product_slug`**. Resolve the product with `Product.friendly.find(params[:product_slug])`. |
| **Serializers in `Api::V1`** | Omitting namespace for top-level serializer classes. | Use **`::OrderSerializer`**, **`::OrderDetailSerializer`**, **`::ShipmentSerializer`**, **`::ReviewSerializer`** in controllers (repo convention). |

### OrderService: sequential order number example

`generate_order_number` derives the suffix from existing rows for that day. Two back-to-back calls with **no** `Order` rows yet both see count `0` and can return the **same** number. The spec should **persist** an order with the first generated `order_number`, then call `generate_order_number` again, so the second value is strictly greater.

### Tooling

Service specs were adjusted for **RuboCop** (`described_class`, `aggregate_failures`, fewer memoized helpers in a single example group).

---

## File Structure

```
craftit-api/
├── app/
│   ├── controllers/api/v1/
│   │   ├── orders_controller.rb               # CREATE
│   │   ├── reviews_controller.rb              # MODIFY — add create action
│   │   └── shipments_controller.rb            # CREATE
│   ├── serializers/
│   │   ├── order_serializer.rb                # CREATE
│   │   ├── order_detail_serializer.rb         # CREATE
│   │   ├── order_item_serializer.rb           # CREATE
│   │   └── shipment_serializer.rb             # CREATE
│   └── services/
│       ├── order_service.rb                   # CREATE
│       └── inventory_service.rb               # CREATE
├── config/
│   └── routes.rb                              # MODIFY
└── spec/
    ├── requests/api/v1/
    │   ├── orders_spec.rb                     # CREATE
    │   ├── reviews_create_spec.rb             # CREATE
    │   └── shipments_spec.rb                  # CREATE
    └── services/
        ├── order_service_spec.rb              # CREATE
        └── inventory_service_spec.rb          # CREATE
```

---

## Task 1: InventoryService

**Files:**
- Create: `app/services/inventory_service.rb`
- Create: `spec/services/inventory_service_spec.rb`

- [ ] **Step 1: Create the services directory**

Run: `mkdir -p app/services spec/services`

- [ ] **Step 2: Write service spec**

Create `spec/services/inventory_service_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe InventoryService do
  let(:product) { create(:product) }
  let(:inventory) { create(:inventory, product: product, stock: 10, reserved_stock: 0) }

  describe ".reserve!" do
    it "increments reserved_stock" do
      InventoryService.reserve!(inventory, 3)
      expect(inventory.reload.reserved_stock).to eq(3)
    end

    it "raises error when insufficient stock" do
      expect {
        InventoryService.reserve!(inventory, 15)
      }.to raise_error(InventoryService::InsufficientStockError)
    end
  end

  describe ".confirm!" do
    it "decrements both stock and reserved_stock" do
      inventory.update!(reserved_stock: 3)

      InventoryService.confirm!(inventory, 3)
      inventory.reload

      expect(inventory.stock).to eq(7)
      expect(inventory.reserved_stock).to eq(0)
    end
  end

  describe ".release!" do
    it "decrements reserved_stock" do
      inventory.update!(reserved_stock: 3)

      InventoryService.release!(inventory, 3)
      expect(inventory.reload.reserved_stock).to eq(0)
    end
  end
end
```

- [ ] **Step 3: Run test to verify it fails**

Run: `bundle exec rspec spec/services/inventory_service_spec.rb`

- [ ] **Step 4: Implement InventoryService**

Create `app/services/inventory_service.rb`:

```ruby
class InventoryService
  class InsufficientStockError < StandardError; end

  def self.reserve!(inventory, quantity)
    raise InsufficientStockError, "Insufficient stock for #{inventory.product.name}" unless inventory.sufficient_stock?(quantity)

    inventory.with_lock do
      inventory.increment!(:reserved_stock, quantity)
    end
  end

  def self.confirm!(inventory, quantity)
    inventory.with_lock do
      inventory.decrement!(:reserved_stock, quantity)
      inventory.decrement!(:stock, quantity)
    end
  end

  def self.release!(inventory, quantity)
    inventory.with_lock do
      inventory.decrement!(:reserved_stock, quantity)
    end
  end
end
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bundle exec rspec spec/services/inventory_service_spec.rb`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app/services/inventory_service.rb spec/services/inventory_service_spec.rb
git commit -m "feat: add InventoryService for stock reservation

reserve! — validates and increments reserved_stock with row lock
confirm! — decrements reserved_stock and stock after payment
release! — decrements reserved_stock on cancellation/timeout"
```

---

## Task 2: OrderService

**Files:**
- Create: `app/services/order_service.rb`
- Create: `spec/services/order_service_spec.rb`

- [ ] **Step 1: Write service spec**

Create `spec/services/order_service_spec.rb`:

```ruby
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

        expect {
          OrderService.create_order!(
            customer_profile: profile,
            address: address,
            customer_name: "Test",
            customer_email: "test@example.com"
          )
        }.to raise_error(InventoryService::InsufficientStockError)

        expect(Order.count).to eq(0)
      end
    end

    context "with empty cart" do
      it "raises error" do
        expect {
          OrderService.create_order!(
            customer_profile: profile,
            address: address,
            customer_name: "Test",
            customer_email: "test@example.com"
          )
        }.to raise_error(OrderService::EmptyCartError)
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/services/order_service_spec.rb`

- [ ] **Step 3: Implement OrderService**

Create `app/services/order_service.rb`:

```ruby
class OrderService
  class EmptyCartError < StandardError; end

  TAX_RATE = BigDecimal("0.16")
  DEFAULT_SHIPPING_COST = BigDecimal("99.00")

  def self.create_order!(customer_profile:, address:, customer_name:, customer_email:)
    cart_items = customer_profile.cart_items.includes(product: :inventory)
    raise EmptyCartError, "Cart is empty" if cart_items.empty?

    ActiveRecord::Base.transaction do
      # Reserve stock for all items
      cart_items.each do |cart_item|
        inventory = cart_item.product.inventory
        raise InventoryService::InsufficientStockError, "#{cart_item.product.name} is out of stock" unless inventory

        InventoryService.reserve!(inventory, cart_item.quantity)
      end

      # Calculate totals
      subtotal = cart_items.sum { |ci| ci.product.price * ci.quantity }
      tax = (subtotal * TAX_RATE).round(2)
      shipping_cost = DEFAULT_SHIPPING_COST
      total = subtotal + tax + shipping_cost

      # Create order
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

      # Create order items with snapshots
      cart_items.each do |cart_item|
        order.order_items.create!(
          product: cart_item.product,
          product_name_snapshot: cart_item.product.name,
          price_snapshot: cart_item.product.price,
          quantity: cart_item.quantity
        )
      end

      # Clear cart
      customer_profile.cart_items.destroy_all

      order
    end
  end

  def self.generate_order_number
    date = Date.current.strftime("%Y%m%d")
    today_count = Order.where("order_number LIKE ?", "CRA-#{date}-%").count
    sequence = format("%04d", today_count + 1)
    "CRA-#{date}-#{sequence}"
  end
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/services/order_service_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/services/order_service.rb spec/services/order_service_spec.rb
git commit -m "feat: add OrderService for checkout flow

Creates order with stock reservation, tax calculation (IVA 16%),
order number generation (CRA-YYYYMMDD-XXXX), price/address
snapshots, and cart clearing. Wrapped in transaction."
```

---

## Task 3: Order Serializers

**Files:**
- Create: `app/serializers/order_serializer.rb`
- Create: `app/serializers/order_detail_serializer.rb`
- Create: `app/serializers/order_item_serializer.rb`
- Create: `app/serializers/shipment_serializer.rb`

- [ ] **Step 1: Create serializers**

Create `app/serializers/order_serializer.rb`:

```ruby
class OrderSerializer
  include JSONAPI::Serializer

  attributes :order_number, :status, :subtotal, :shipping_cost,
    :tax, :total, :created_at

  attribute :item_count do |order|
    order.order_items.size
  end
end
```

Create `app/serializers/order_detail_serializer.rb`:

```ruby
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
```

Create `app/serializers/order_item_serializer.rb`:

```ruby
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
```

Create `app/serializers/shipment_serializer.rb`:

```ruby
class ShipmentSerializer
  include JSONAPI::Serializer

  attributes :carrier, :tracking_number, :tracking_url,
    :status, :estimated_delivery, :created_at, :updated_at
end
```

- [ ] **Step 2: Commit**

```bash
git add app/serializers/
git commit -m "feat: add Order, OrderDetail, OrderItem, Shipment serializers"
```

---

## Task 4: Orders Controller

**Files:**
- Create: `app/controllers/api/v1/orders_controller.rb`
- Create: `spec/requests/api/v1/orders_spec.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Add order routes**

In `config/routes.rb`, inside `namespace :v1`, add:

```ruby
      resources :orders, only: %i[index show create], param: :order_number do
        get "shipment", to: "shipments#show", on: :member
      end
```

Use a **member** `shipment` route so `params[:order_number]` stays a single segment (see **Implementation notes** above). A nested singular `resource :shipment` would expose an awkward parent param name (`order_order_number`).

- [ ] **Step 2: Write request specs**

Create `spec/requests/api/v1/orders_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Orders", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "GET /api/v1/orders" do
    it "returns 401 without authentication" do
      get "/api/v1/orders"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns user orders" do
      create(:order, customer_profile: profile)
      create(:order) # another user's order

      authenticated_get "/api/v1/orders", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end
  end

  describe "GET /api/v1/orders/:order_number" do
    it "returns order detail" do
      order = create(:order, customer_profile: profile)
      create(:order_item, order: order)

      authenticated_get "/api/v1/orders/#{order.order_number}", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data[:attributes][:order_number]).to eq(order.order_number)
      expect(json_data[:attributes][:items]).to be_present
    end

    it "returns 404 for another user's order" do
      other_order = create(:order)

      authenticated_get "/api/v1/orders/#{other_order.order_number}", customer_profile: profile

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/orders" do
    it "creates an order from the cart" do
      product = create(:product, price: 500.00)
      create(:inventory, product: product, stock: 10)
      create(:cart_item, customer_profile: profile, product: product, quantity: 2)
      address = create(:address, customer_profile: profile)

      authenticated_post "/api/v1/orders",
        customer_profile: profile,
        params: {
          address_id: address.id,
          customer_name: "Test User",
          customer_email: "test@example.com"
        }

      expect(response).to have_http_status(:created)
      expect(json_data[:attributes][:status]).to eq("pending")
      expect(json_data[:attributes][:order_number]).to match(/\ACRA-/)
    end

    it "returns 422 for empty cart" do
      address = create(:address, customer_profile: profile)

      authenticated_post "/api/v1/orders",
        customer_profile: profile,
        params: {
          address_id: address.id,
          customer_name: "Test",
          customer_email: "test@example.com"
        }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 for insufficient stock" do
      product = create(:product, price: 100)
      create(:inventory, product: product, stock: 1)
      create(:cart_item, customer_profile: profile, product: product, quantity: 5)
      address = create(:address, customer_profile: profile)

      authenticated_post "/api/v1/orders",
        customer_profile: profile,
        params: {
          address_id: address.id,
          customer_name: "Test",
          customer_email: "test@example.com"
        }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_error[:code]).to eq("insufficient_stock")
    end
  end
end
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/orders_spec.rb`

- [ ] **Step 4: Implement OrdersController**

Create `app/controllers/api/v1/orders_controller.rb`:

```ruby
module Api
  module V1
    class OrdersController < BaseController
      before_action :authenticate!

      def index
        orders = current_customer_profile.orders
          .includes(:order_items)
          .order(created_at: :desc)

        pagy, records = pagy(orders)

        render_success(
          ::OrderSerializer.new(records).serializable_hash[:data],
          meta: pagination_meta(pagy)
        )
      end

      def show
        order = current_customer_profile.orders
          .includes(:order_items, :payment, :shipment)
          .find_by!(order_number: params[:order_number])

        render_success(::OrderDetailSerializer.new(order).serializable_hash[:data])
      end

      def create
        address = current_customer_profile.addresses.find(params[:address_id])

        order = OrderService.create_order!(
          customer_profile: current_customer_profile,
          address: address,
          customer_name: params[:customer_name],
          customer_email: params[:customer_email]
        )

        render_created(::OrderDetailSerializer.new(order).serializable_hash[:data])
      rescue OrderService::EmptyCartError => e
        render_error(code: "validation_error", message: e.message, status: :unprocessable_entity)
      rescue InventoryService::InsufficientStockError => e
        render_error(code: "insufficient_stock", message: e.message, status: :unprocessable_entity)
      end
    end
  end
end
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/orders_spec.rb`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app/controllers/api/v1/orders_controller.rb spec/requests/api/v1/orders_spec.rb config/routes.rb
git commit -m "feat: add Orders API (list, detail, create)

GET /api/v1/orders — paginated order history
GET /api/v1/orders/:order_number — detail with items/payment/shipment
POST /api/v1/orders — create order from cart via OrderService"
```

---

## Task 5: Shipments Controller (Customer View)

**Files:**
- Create: `app/controllers/api/v1/shipments_controller.rb`
- Create: `spec/requests/api/v1/shipments_spec.rb`

- [ ] **Step 1: Write request specs**

Create `spec/requests/api/v1/shipments_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Shipments", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "GET /api/v1/orders/:order_number/shipment" do
    it "returns shipment details" do
      order = create(:order, :shipped, customer_profile: profile)
      shipment = create(:shipment, order: order, carrier: "DHL", tracking_number: "ABC123")

      authenticated_get "/api/v1/orders/#{order.order_number}/shipment", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data[:attributes][:carrier]).to eq("DHL")
      expect(json_data[:attributes][:tracking_number]).to eq("ABC123")
    end

    it "returns 404 when no shipment exists" do
      order = create(:order, customer_profile: profile)

      authenticated_get "/api/v1/orders/#{order.order_number}/shipment", customer_profile: profile

      expect(response).to have_http_status(:not_found)
    end
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/shipments_spec.rb`

- [ ] **Step 3: Implement ShipmentsController**

Create `app/controllers/api/v1/shipments_controller.rb`:

```ruby
module Api
  module V1
    class ShipmentsController < BaseController
      before_action :authenticate!

      def show
        order = current_customer_profile.orders
          .find_by!(order_number: params[:order_number])

        shipment = order.shipment
        return render_not_found("No shipment found for this order") unless shipment

        render_success(::ShipmentSerializer.new(shipment).serializable_hash[:data])
      end
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/shipments_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/api/v1/shipments_controller.rb spec/requests/api/v1/shipments_spec.rb
git commit -m "feat: add Shipments API (customer view)

GET /api/v1/orders/:order_number/shipment — tracking info"
```

---

## Task 6: Review Creation (Authenticated)

**Files:**
- Modify: `app/controllers/api/v1/reviews_controller.rb`
- Create: `spec/requests/api/v1/reviews_create_spec.rb`

- [ ] **Step 1: Write request specs for review creation**

Create `spec/requests/api/v1/reviews_create_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Reviews (create)", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "POST /api/v1/products/:slug/reviews" do
    it "creates a review for a product" do
      product = create(:product)

      authenticated_post "/api/v1/products/#{product.slug}/reviews",
        customer_profile: profile,
        params: { rating: 5, title: "Amazing!", body: "Love this figure" }

      expect(response).to have_http_status(:created)
      expect(product.reviews.count).to eq(1)
    end

    it "returns 401 without authentication" do
      product = create(:product)

      post "/api/v1/products/#{product.slug}/reviews",
        params: { rating: 5, title: "Test" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 422 for invalid rating" do
      product = create(:product)

      authenticated_post "/api/v1/products/#{product.slug}/reviews",
        customer_profile: profile,
        params: { rating: 6, title: "Bad rating" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/reviews_create_spec.rb`

- [ ] **Step 3: Add create route for reviews**

In `config/routes.rb`, update the products resource to include review creation:

```ruby
      resources :products, only: %i[index show], param: :slug do
        resources :reviews, only: %i[index create]
      end
```

Nested `resources :reviews` is valid here (no `on: :member` on the inner resource). The `index` action remains public (no auth), while `create` requires auth (handled in the controller).

- [ ] **Step 4: Update ReviewsController with create action**

Add to `app/controllers/api/v1/reviews_controller.rb`:

```ruby
      before_action :authenticate!, only: [ :create ]

      def create
        product = ::Product.friendly.find(params[:product_slug])
        review = product.reviews.build(review_params)
        review.customer_profile = current_customer_profile

        if review.save
          render_created(::ReviewSerializer.new(review).serializable_hash[:data])
        else
          render_validation_error(review)
        end
      end

      private

      def review_params
        params.permit(:rating, :title, :body)
      end
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/reviews_create_spec.rb`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app/controllers/api/v1/reviews_controller.rb spec/requests/api/v1/reviews_create_spec.rb config/routes.rb
git commit -m "feat: add review creation (authenticated)

POST /api/v1/products/:slug/reviews — create review (immutable in v1).
Public listing remains unauthenticated."
```

---

## Task 7: Final Verification

- [ ] **Step 1: Run full test suite**

Run: `bundle exec rspec --format documentation`
Expected: All specs pass.

- [ ] **Step 2: Run RuboCop**

Run: `bundle exec rubocop`
Expected: No offenses.

- [ ] **Step 3: Verify routes**

Run: `rails routes | grep api`
Expected: All order, shipment, and review routes listed correctly.
