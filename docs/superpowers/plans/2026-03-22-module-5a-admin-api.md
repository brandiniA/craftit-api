# Module 5A: Admin API Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build admin-only API endpoints for product management (CRUD), order management (status updates, shipment creation), inventory management (stock updates, low-stock alerts), customer listing, and a dashboard stats endpoint.

**Architecture:** Admin endpoints live under `/api/v1/admin/`. Admin authorization checks JWT + email match against `ADMIN_EMAIL` env var. Admin controllers inherit from an `Admin::BaseController` that enforces admin access.

**Tech Stack:** Rails 8.1, RSpec request specs, FactoryBot

**Spec reference:** `craftitapp/docs/superpowers/specs/2026-03-21-backend-architecture-design.md` — API Endpoints > Admin

**Depends on:** Modules 1-4 must be completed first.

---

## File Structure

```
craftit-api/
├── app/controllers/api/v1/admin/
│   ├── base_controller.rb                     # CREATE — admin auth check
│   ├── products_controller.rb                 # CREATE
│   ├── orders_controller.rb                   # CREATE
│   ├── inventory_controller.rb                # CREATE
│   ├── customers_controller.rb                # CREATE
│   └── dashboard_controller.rb                # CREATE
├── config/
│   └── routes.rb                              # MODIFY — add admin namespace
└── spec/
    ├── requests/api/v1/admin/
    │   ├── products_spec.rb                   # CREATE
    │   ├── orders_spec.rb                     # CREATE
    │   ├── inventory_spec.rb                  # CREATE
    │   ├── customers_spec.rb                  # CREATE
    │   └── dashboard_spec.rb                  # CREATE
    └── support/
        └── auth_helpers.rb                    # MODIFY — add admin_headers helper
```

---

## Task 1: Admin Base Controller and Auth

**Files:**
- Create: `app/controllers/api/v1/admin/base_controller.rb`
- Modify: `spec/support/auth_helpers.rb`

- [ ] **Step 1: Add admin_headers to AuthHelpers**

In `spec/support/auth_helpers.rb`, add:

```ruby
  def admin_headers
    { "auth_user_id" => "admin-user", "auth_user_email" => ENV.fetch("ADMIN_EMAIL", "admin@craftitapp.com") }
  end

  def admin_get(path, **options)
    get path, headers: admin_headers, **options
  end

  def admin_post(path, **options)
    post path, headers: admin_headers, **options
  end

  def admin_patch(path, **options)
    patch path, headers: admin_headers, **options
  end

  def admin_delete(path, **options)
    delete path, headers: admin_headers, **options
  end
```

- [ ] **Step 2: Update JWT middleware to also pass email**

In `app/middleware/jwt_authentication.rb`, update the `call` method to also extract email:

```ruby
    if token
      payload = decode_token(token)
      if payload
        env["auth_user_id"] = payload["sub"]
        env["auth_user_email"] = payload["email"]
      end
    end
```

And update the test header section to guard it with environment check:

```ruby
    if Rails.env.test? && env["HTTP_AUTH_USER_ID"].present?
      env["auth_user_id"] = env["HTTP_AUTH_USER_ID"]
      env["auth_user_email"] = env["HTTP_AUTH_USER_EMAIL"]
      return @app.call(env)
    end
```

- [ ] **Step 3: Add current_auth_user_email to BaseController**

In `app/controllers/api/v1/base_controller.rb`, add to private section:

```ruby
      def current_auth_user_email
        request.env["auth_user_email"]
      end
```

- [ ] **Step 4: Create Admin::BaseController**

Run: `mkdir -p app/controllers/api/v1/admin`

Create `app/controllers/api/v1/admin/base_controller.rb`:

```ruby
module Api
  module V1
    module Admin
      class BaseController < Api::V1::BaseController
        before_action :authenticate!
        before_action :authorize_admin!

        private

        def authorize_admin!
          admin_email = ENV.fetch("ADMIN_EMAIL", nil)
          return render_forbidden("Admin access required") unless admin_email.present?
          return render_forbidden("Admin access required") unless current_auth_user_email == admin_email
        end
      end
    end
  end
end
```

- [ ] **Step 5: Write spec to verify admin auth**

Create `spec/requests/api/v1/admin/auth_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Admin Authorization", type: :request do
  before do
    ENV["ADMIN_EMAIL"] = "admin@craftitapp.com"
  end

  it "allows admin email" do
    admin_get "/api/v1/admin/dashboard/stats"
    expect(response).not_to have_http_status(:forbidden)
  end

  it "rejects non-admin email" do
    profile = create(:customer_profile)
    authenticated_get "/api/v1/admin/dashboard/stats", customer_profile: profile
    expect(response).to have_http_status(:forbidden)
  end

  it "rejects unauthenticated requests" do
    get "/api/v1/admin/dashboard/stats"
    expect(response).to have_http_status(:unauthorized)
  end
end
```

Note: This test depends on the dashboard route existing. We'll create it in Task 6, but add the route now for the test to work.

- [ ] **Step 6: Add admin namespace to routes**

In `config/routes.rb`, inside `namespace :v1`, add:

```ruby
      namespace :admin do
        resources :products, only: [ :index, :create, :update, :destroy ] do
          post "images", on: :member
        end
        resources :orders, only: [ :index ] do
          patch "status", on: :member
          post "shipment", on: :member
        end
        resources :inventory, only: [ :index, :update ], controller: "inventory" do
          get "low-stock", on: :collection, action: :low_stock
        end
        resources :customers, only: [ :index, :show ]

        namespace :dashboard do
          get "stats", to: "stats#show" if false # placeholder
        end
        get "dashboard/stats", to: "dashboard#stats"
      end
```

- [ ] **Step 7: Commit**

```bash
git add app/controllers/api/v1/admin/base_controller.rb app/middleware/jwt_authentication.rb app/controllers/api/v1/base_controller.rb spec/support/auth_helpers.rb config/routes.rb
git commit -m "feat: add Admin base controller with email authorization

Admin access verified by matching JWT email against ADMIN_EMAIL
env var. Admin::BaseController inherits from V1::BaseController."
```

---

## Task 2: Admin Products Controller

**Files:**
- Create: `app/controllers/api/v1/admin/products_controller.rb`
- Create: `spec/requests/api/v1/admin/products_spec.rb`

- [ ] **Step 1: Write request specs**

Create `spec/requests/api/v1/admin/products_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Admin::Products", type: :request do
  before { ENV["ADMIN_EMAIL"] = "admin@craftitapp.com" }

  describe "GET /api/v1/admin/products" do
    it "returns all products (including inactive)" do
      create(:product, is_active: true)
      create(:product, is_active: false)

      admin_get "/api/v1/admin/products"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(2)
    end
  end

  describe "POST /api/v1/admin/products" do
    it "creates a product" do
      category = create(:category)

      admin_post "/api/v1/admin/products", params: {
        name: "New Figure",
        price: 599.99,
        sku: "FIG-NEW-001",
        description: "A new figure",
        category_id: category.id
      }

      expect(response).to have_http_status(:created)
      expect(Product.last.name).to eq("New Figure")
    end

    it "creates inventory alongside product" do
      admin_post "/api/v1/admin/products", params: {
        name: "New Figure",
        price: 599.99,
        sku: "FIG-NEW-002",
        initial_stock: 25
      }

      expect(response).to have_http_status(:created)
      expect(Product.last.inventory.stock).to eq(25)
    end

    it "returns 422 for invalid data" do
      admin_post "/api/v1/admin/products", params: { name: "" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/admin/products/:id" do
    it "updates a product" do
      product = create(:product, name: "Old Name")

      admin_patch "/api/v1/admin/products/#{product.id}", params: { name: "New Name" }

      expect(response).to have_http_status(:ok)
      expect(product.reload.name).to eq("New Name")
    end
  end

  describe "DELETE /api/v1/admin/products/:id" do
    it "soft deletes (deactivates) the product" do
      product = create(:product, is_active: true)

      admin_delete "/api/v1/admin/products/#{product.id}"

      expect(response).to have_http_status(:ok)
      expect(product.reload.is_active).to be false
    end
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/admin/products_spec.rb`

- [ ] **Step 3: Implement Admin::ProductsController**

Create `app/controllers/api/v1/admin/products_controller.rb`:

```ruby
module Api
  module V1
    module Admin
      class ProductsController < Admin::BaseController
        def index
          products = Product.includes(:category, :images, :inventory)
            .order(created_at: :desc)

          pagy, records = pagy(products)

          render_success(
            ProductSerializer.new(records).serializable_hash[:data],
            meta: pagination_meta(pagy)
          )
        end

        def create
          product = Product.new(product_params)

          ActiveRecord::Base.transaction do
            product.save!
            initial_stock = params[:initial_stock]&.to_i || 0
            Inventory.create!(product: product, stock: initial_stock)
          end

          render_created(ProductDetailSerializer.new(product.reload).serializable_hash[:data])
        rescue ActiveRecord::RecordInvalid => e
          render_validation_error(e.record)
        end

        def update
          product = Product.find(params[:id])

          if product.update(product_params)
            render_success(ProductDetailSerializer.new(product).serializable_hash[:data])
          else
            render_validation_error(product)
          end
        end

        def destroy
          product = Product.find(params[:id])
          product.update!(is_active: false)

          render_success({ message: "Product deactivated" })
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/admin/products_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/api/v1/admin/products_controller.rb spec/requests/api/v1/admin/products_spec.rb
git commit -m "feat: add Admin Products API (CRUD)

GET /api/v1/admin/products — all products including inactive
POST /api/v1/admin/products — create with optional initial_stock
PATCH /api/v1/admin/products/:id — update
DELETE /api/v1/admin/products/:id — soft delete (deactivate)"
```

---

## Task 3: Admin Orders Controller

**Files:**
- Create: `app/controllers/api/v1/admin/orders_controller.rb`
- Create: `spec/requests/api/v1/admin/orders_spec.rb`

- [ ] **Step 1: Write request specs**

Create `spec/requests/api/v1/admin/orders_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Admin::Orders", type: :request do
  before { ENV["ADMIN_EMAIL"] = "admin@craftitapp.com" }

  describe "GET /api/v1/admin/orders" do
    it "returns all orders" do
      create_list(:order, 3)

      admin_get "/api/v1/admin/orders"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
    end

    it "filters by status" do
      create(:order, :paid)
      create(:order, :pending)

      admin_get "/api/v1/admin/orders", params: { status: "paid" }

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end
  end

  describe "PATCH /api/v1/admin/orders/:id/status" do
    it "transitions order status" do
      order = create(:order, :paid)

      admin_patch "/api/v1/admin/orders/#{order.id}/status",
        params: { status: "processing" }

      expect(response).to have_http_status(:ok)
      expect(order.reload.status).to eq("processing")
    end

    it "returns 422 for invalid transition" do
      order = create(:order, :delivered)

      admin_patch "/api/v1/admin/orders/#{order.id}/status",
        params: { status: "cancelled" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /api/v1/admin/orders/:id/shipment" do
    it "creates a shipment and transitions order to shipped" do
      order = create(:order, :processing)

      admin_post "/api/v1/admin/orders/#{order.id}/shipment",
        params: {
          carrier: "DHL",
          tracking_number: "DHL123456",
          tracking_url: "https://dhl.com/track/DHL123456",
          estimated_delivery: "2026-03-29"
        }

      expect(response).to have_http_status(:created)
      expect(order.reload.status).to eq("shipped")
      expect(order.shipment.carrier).to eq("DHL")
    end
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/admin/orders_spec.rb`

- [ ] **Step 3: Implement Admin::OrdersController**

Create `app/controllers/api/v1/admin/orders_controller.rb`:

```ruby
module Api
  module V1
    module Admin
      class OrdersController < Admin::BaseController
        def index
          orders = Order.includes(:customer_profile, :order_items)
            .order(created_at: :desc)

          orders = orders.where(status: params[:status]) if params[:status].present?

          pagy, records = pagy(orders)

          render_success(
            OrderSerializer.new(records).serializable_hash[:data],
            meta: pagination_meta(pagy)
          )
        end

        def status
          order = Order.find(params[:id])

          event = status_event(params[:status])
          unless event && order.send(:"may_#{event}?")
            return render_error(
              code: "validation_error",
              message: "Cannot transition to #{params[:status]}",
              status: :unprocessable_entity
            )
          end

          order.send(:"#{event}!")
          render_success(OrderDetailSerializer.new(order).serializable_hash[:data])
        end

        def shipment
          order = Order.find(params[:id])

          shipment = order.create_shipment!(shipment_params)
          order.ship! if order.may_ship?

          render_created(ShipmentSerializer.new(shipment).serializable_hash[:data])
        rescue ActiveRecord::RecordInvalid => e
          render_validation_error(e.record)
        end

        private

        def shipment_params
          params.permit(:carrier, :tracking_number, :tracking_url, :estimated_delivery)
        end

        def status_event(target_status)
          {
            "paid" => "pay",
            "processing" => "process",
            "shipped" => "ship",
            "delivered" => "deliver",
            "cancelled" => "cancel"
          }[target_status]
        end
      end
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/admin/orders_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/api/v1/admin/orders_controller.rb spec/requests/api/v1/admin/orders_spec.rb
git commit -m "feat: add Admin Orders API (list, status update, shipment)

GET /api/v1/admin/orders — all orders, filterable by status
PATCH /api/v1/admin/orders/:id/status — transition order state
POST /api/v1/admin/orders/:id/shipment — create shipment + ship"
```

---

## Task 4: Admin Inventory Controller

**Files:**
- Create: `app/controllers/api/v1/admin/inventory_controller.rb`
- Create: `spec/requests/api/v1/admin/inventory_spec.rb`

- [ ] **Step 1: Write request specs**

Create `spec/requests/api/v1/admin/inventory_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Admin::Inventory", type: :request do
  before { ENV["ADMIN_EMAIL"] = "admin@craftitapp.com" }

  describe "GET /api/v1/admin/inventory" do
    it "returns all inventory" do
      create_list(:product, 3, :with_inventory)

      admin_get "/api/v1/admin/inventory"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
    end
  end

  describe "GET /api/v1/admin/inventory/low-stock" do
    it "returns only low stock items" do
      p1 = create(:product)
      p2 = create(:product)
      create(:inventory, product: p1, stock: 2, low_stock_threshold: 5)
      create(:inventory, product: p2, stock: 50, low_stock_threshold: 5)

      admin_get "/api/v1/admin/inventory/low-stock"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end
  end

  describe "PATCH /api/v1/admin/inventory/:product_id" do
    it "updates stock for a product" do
      product = create(:product)
      inventory = create(:inventory, product: product, stock: 10)

      admin_patch "/api/v1/admin/inventory/#{product.id}",
        params: { stock: 50, low_stock_threshold: 10 }

      expect(response).to have_http_status(:ok)
      expect(inventory.reload.stock).to eq(50)
      expect(inventory.reload.low_stock_threshold).to eq(10)
    end
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/admin/inventory_spec.rb`

- [ ] **Step 3: Implement Admin::InventoryController**

Create `app/controllers/api/v1/admin/inventory_controller.rb`:

```ruby
module Api
  module V1
    module Admin
      class InventoryController < Admin::BaseController
        def index
          inventories = Inventory.includes(:product)
            .order(:id)

          pagy, records = pagy(inventories)

          render_success(
            records.map { |inv| inventory_json(inv) },
            meta: pagination_meta(pagy)
          )
        end

        def low_stock
          inventories = Inventory.low_stock.includes(:product)

          render_success(inventories.map { |inv| inventory_json(inv) })
        end

        def update
          inventory = Inventory.find_by!(product_id: params[:id])

          if inventory.update(inventory_params)
            render_success(inventory_json(inventory))
          else
            render_validation_error(inventory)
          end
        end

        private

        def inventory_params
          params.permit(:stock, :low_stock_threshold)
        end

        def inventory_json(inventory)
          {
            product_id: inventory.product_id,
            product_name: inventory.product.name,
            product_sku: inventory.product.sku,
            stock: inventory.stock,
            reserved_stock: inventory.reserved_stock,
            available_stock: inventory.available_stock,
            low_stock_threshold: inventory.low_stock_threshold,
            low_stock: inventory.low_stock?
          }
        end
      end
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/admin/inventory_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/api/v1/admin/inventory_controller.rb spec/requests/api/v1/admin/inventory_spec.rb
git commit -m "feat: add Admin Inventory API (list, low-stock, update)

GET /api/v1/admin/inventory — all inventory with stock details
GET /api/v1/admin/inventory/low-stock — items below threshold
PATCH /api/v1/admin/inventory/:product_id — update stock levels"
```

---

## Task 5: Admin Customers and Dashboard

**Files:**
- Create: `app/controllers/api/v1/admin/customers_controller.rb`
- Create: `app/controllers/api/v1/admin/dashboard_controller.rb`
- Create: `spec/requests/api/v1/admin/customers_spec.rb`
- Create: `spec/requests/api/v1/admin/dashboard_spec.rb`

- [ ] **Step 1: Implement Admin::CustomersController**

Create `app/controllers/api/v1/admin/customers_controller.rb`:

```ruby
module Api
  module V1
    module Admin
      class CustomersController < Admin::BaseController
        def index
          profiles = CustomerProfile.order(created_at: :desc)

          pagy, records = pagy(profiles)

          render_success(
            ProfileSerializer.new(records).serializable_hash[:data],
            meta: pagination_meta(pagy)
          )
        end

        def show
          profile = CustomerProfile.find(params[:id])

          render_success(
            ProfileSerializer.new(profile).serializable_hash[:data]
          )
        end
      end
    end
  end
end
```

- [ ] **Step 2: Implement Admin::DashboardController**

Create `app/controllers/api/v1/admin/dashboard_controller.rb`:

```ruby
module Api
  module V1
    module Admin
      class DashboardController < Admin::BaseController
        def stats
          render_success({
            total_products: Product.count,
            active_products: Product.active.count,
            total_orders: Order.count,
            pending_orders: Order.pending.count,
            processing_orders: Order.processing.count,
            total_revenue: Order.where(status: [ :paid, :processing, :shipped, :delivered ]).sum(:total),
            total_customers: CustomerProfile.count,
            low_stock_count: Inventory.low_stock.count
          })
        end
      end
    end
  end
end
```

- [ ] **Step 3: Write specs**

Create `spec/requests/api/v1/admin/customers_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Admin::Customers", type: :request do
  before { ENV["ADMIN_EMAIL"] = "admin@craftitapp.com" }

  describe "GET /api/v1/admin/customers" do
    it "returns all customer profiles" do
      create_list(:customer_profile, 3)

      admin_get "/api/v1/admin/customers"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
    end
  end

  describe "GET /api/v1/admin/customers/:id" do
    it "returns a specific customer" do
      profile = create(:customer_profile)

      admin_get "/api/v1/admin/customers/#{profile.id}"

      expect(response).to have_http_status(:ok)
    end
  end
end
```

Create `spec/requests/api/v1/admin/dashboard_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Admin::Dashboard", type: :request do
  before { ENV["ADMIN_EMAIL"] = "admin@craftitapp.com" }

  describe "GET /api/v1/admin/dashboard/stats" do
    it "returns dashboard statistics" do
      create(:product, :with_inventory)
      create(:order, :processing)

      admin_get "/api/v1/admin/dashboard/stats"

      expect(response).to have_http_status(:ok)
      expect(json_data).to have_key(:total_products)
      expect(json_data).to have_key(:total_orders)
      expect(json_data).to have_key(:total_revenue)
      expect(json_data).to have_key(:low_stock_count)
    end
  end
end
```

- [ ] **Step 4: Run all admin specs**

Run: `bundle exec rspec spec/requests/api/v1/admin/`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/controllers/api/v1/admin/customers_controller.rb app/controllers/api/v1/admin/dashboard_controller.rb spec/requests/api/v1/admin/
git commit -m "feat: add Admin Customers and Dashboard APIs

GET /api/v1/admin/customers — list all customer profiles
GET /api/v1/admin/customers/:id — customer detail
GET /api/v1/admin/dashboard/stats — aggregate store statistics"
```

---

## Task 6: Final Verification

- [ ] **Step 1: Run full test suite**

Run: `bundle exec rspec --format documentation`
Expected: All specs pass.

- [ ] **Step 2: Run RuboCop**

Run: `bundle exec rubocop`

- [ ] **Step 3: Verify all admin routes**

Run: `rails routes | grep admin`
Expected: All admin routes listed.
