# Module 4A: Authenticated API — User Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build authenticated API endpoints for Cart (CRUD + sync), Wishlist (CRUD), Profile (read/update), and Addresses (CRUD). All require JWT authentication and scope data to the current user's customer profile.

**Architecture:** Controllers use `before_action :authenticate!` and resolve the current user via `current_customer_profile` (auto-created on first request). All data is scoped to the authenticated user's customer profile.

**Tech Stack:** Rails 8.1, RSpec request specs, FactoryBot

**Spec reference:** `craftitapp/docs/superpowers/specs/2026-03-21-backend-architecture-design.md` — API Endpoints > Authenticated

**Depends on:** Modules 1, 2A, 2B, and 3 must be completed first.

---

## File Structure

```
craftit-api/
├── app/controllers/api/v1/
│   ├── base_controller.rb                     # MODIFY — add current_customer_profile
│   ├── cart_controller.rb                     # CREATE
│   ├── wishlist_controller.rb                 # CREATE
│   ├── profile_controller.rb                  # CREATE
│   └── addresses_controller.rb                # CREATE
├── app/serializers/
│   ├── cart_item_serializer.rb                # CREATE
│   ├── wishlist_item_serializer.rb            # CREATE
│   ├── profile_serializer.rb                  # CREATE
│   └── address_serializer.rb                  # CREATE
├── spec/
│   ├── requests/api/v1/
│   │   ├── cart_spec.rb                       # CREATE
│   │   ├── wishlist_spec.rb                   # CREATE
│   │   ├── profile_spec.rb                    # CREATE
│   │   └── addresses_spec.rb                  # CREATE
│   └── support/
│       └── auth_helpers.rb                    # CREATE — JWT test helpers
```

---

## Task 1: JWT Test Helpers

**Files:**
- Create: `spec/support/auth_helpers.rb`

- [ ] **Step 1: Create auth helpers for request specs**

Create `spec/support/auth_helpers.rb`:

```ruby
module AuthHelpers
  def auth_headers(customer_profile)
    # In tests, we bypass real JWT by setting the env directly
    # The middleware reads auth_user_id from the env
    { "auth_user_id" => customer_profile.auth_user_id }
  end

  def authenticated_get(path, customer_profile:, **options)
    get path, headers: auth_headers(customer_profile), **options
  end

  def authenticated_post(path, customer_profile:, **options)
    post path, headers: auth_headers(customer_profile), **options
  end

  def authenticated_patch(path, customer_profile:, **options)
    patch path, headers: auth_headers(customer_profile), **options
  end

  def authenticated_delete(path, customer_profile:, **options)
    delete path, headers: auth_headers(customer_profile), **options
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
```

- [ ] **Step 2: Update JwtAuthentication middleware to support test header**

In `app/middleware/jwt_authentication.rb`, update the `call` method to also check for a direct header (used only in test environment):

```ruby
  def call(env)
    # Test support: allow direct auth_user_id header (test environment ONLY)
    if Rails.env.test? && env["HTTP_AUTH_USER_ID"].present?
      env["auth_user_id"] = env["HTTP_AUTH_USER_ID"]
      return @app.call(env)
    end

    token = extract_token(env)

    if token
      payload = decode_token(token)
      env["auth_user_id"] = payload&.dig("sub") if payload
    end

    @app.call(env)
  end
```

- [ ] **Step 3: Commit**

```bash
git add spec/support/auth_helpers.rb app/middleware/jwt_authentication.rb
git commit -m "feat: add JWT test helpers for authenticated request specs

AuthHelpers module provides authenticated_get/post/patch/delete
methods. Middleware supports direct auth_user_id header for testing."
```

---

## Task 2: Add current_customer_profile to BaseController

**Files:**
- Modify: `app/controllers/api/v1/base_controller.rb`

- [ ] **Step 1: Add current_customer_profile method**

Add to the private section of `app/controllers/api/v1/base_controller.rb`:

```ruby
      def current_customer_profile
        return nil unless current_auth_user_id

        @current_customer_profile ||= CustomerProfile.find_or_create_by!(
          auth_user_id: current_auth_user_id
        )
      end
```

- [ ] **Step 2: Commit**

```bash
git add app/controllers/api/v1/base_controller.rb
git commit -m "feat: add current_customer_profile to BaseController

Auto-creates CustomerProfile on first authenticated request.
Uses find_or_create_by! with auth_user_id from JWT."
```

---

## Task 3: Cart Controller

**Files:**
- Create: `app/serializers/cart_item_serializer.rb`
- Create: `app/controllers/api/v1/cart_controller.rb`
- Create: `spec/requests/api/v1/cart_spec.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Create CartItemSerializer**

Create `app/serializers/cart_item_serializer.rb`:

```ruby
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
```

- [ ] **Step 2: Add cart routes**

In `config/routes.rb`, inside `namespace :v1`, add:

```ruby
      resource :cart, only: [ :show ], controller: "cart" do
        resources :items, only: [ :create, :update, :destroy ], controller: "cart", as: :cart_items
        post "sync", on: :collection
      end
```

Note: This maps to:
- `GET /api/v1/cart` → `cart#show`
- `POST /api/v1/cart/items` → `cart#create`
- `PATCH /api/v1/cart/items/:id` → `cart#update`
- `DELETE /api/v1/cart/items/:id` → `cart#destroy`
- `POST /api/v1/cart/sync` → `cart#sync`

- [ ] **Step 3: Write request specs**

Create `spec/requests/api/v1/cart_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Cart", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "GET /api/v1/cart" do
    it "returns 401 without authentication" do
      get "/api/v1/cart"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns cart items for authenticated user" do
      product = create(:product, :with_inventory)
      create(:cart_item, customer_profile: profile, product: product, quantity: 2)

      authenticated_get "/api/v1/cart", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end

    it "returns empty cart for new user" do
      authenticated_get "/api/v1/cart", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data).to be_empty
    end
  end

  describe "POST /api/v1/cart/items" do
    it "adds a product to cart" do
      product = create(:product, :with_inventory)

      authenticated_post "/api/v1/cart/items",
        customer_profile: profile,
        params: { product_id: product.id, quantity: 2 }

      expect(response).to have_http_status(:created)
      expect(profile.cart_items.count).to eq(1)
      expect(profile.cart_items.first.quantity).to eq(2)
    end

    it "increments quantity if product already in cart" do
      product = create(:product, :with_inventory)
      create(:cart_item, customer_profile: profile, product: product, quantity: 1)

      authenticated_post "/api/v1/cart/items",
        customer_profile: profile,
        params: { product_id: product.id, quantity: 2 }

      expect(response).to have_http_status(:ok)
      expect(profile.cart_items.first.quantity).to eq(3)
    end

    it "returns 422 for invalid quantity" do
      product = create(:product, :with_inventory)

      authenticated_post "/api/v1/cart/items",
        customer_profile: profile,
        params: { product_id: product.id, quantity: 0 }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/cart/items/:id" do
    it "updates cart item quantity" do
      product = create(:product, :with_inventory)
      item = create(:cart_item, customer_profile: profile, product: product, quantity: 1)

      authenticated_patch "/api/v1/cart/items/#{item.id}",
        customer_profile: profile,
        params: { quantity: 5 }

      expect(response).to have_http_status(:ok)
      expect(item.reload.quantity).to eq(5)
    end

    it "cannot update another user's cart item" do
      other_profile = create(:customer_profile)
      item = create(:cart_item, customer_profile: other_profile)

      authenticated_patch "/api/v1/cart/items/#{item.id}",
        customer_profile: profile,
        params: { quantity: 5 }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/cart/items/:id" do
    it "removes item from cart" do
      item = create(:cart_item, customer_profile: profile)

      authenticated_delete "/api/v1/cart/items/#{item.id}", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(profile.cart_items.count).to eq(0)
    end
  end

  describe "POST /api/v1/cart/sync" do
    it "merges local cart items into server cart" do
      product1 = create(:product, :with_inventory)
      product2 = create(:product, :with_inventory)
      create(:cart_item, customer_profile: profile, product: product1, quantity: 1)

      authenticated_post "/api/v1/cart/sync",
        customer_profile: profile,
        params: {
          items: [
            { product_id: product1.id, quantity: 2 },
            { product_id: product2.id, quantity: 1 }
          ]
        }

      expect(response).to have_http_status(:ok)
      expect(profile.cart_items.count).to eq(2)
      expect(profile.cart_items.find_by(product: product1).quantity).to eq(3) # 1 + 2
      expect(profile.cart_items.find_by(product: product2).quantity).to eq(1)
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/cart_spec.rb`

- [ ] **Step 5: Implement CartController**

Create `app/controllers/api/v1/cart_controller.rb`:

```ruby
module Api
  module V1
    class CartController < BaseController
      before_action :authenticate!

      def show
        items = current_customer_profile.cart_items
          .includes(product: [ :images, :inventory ])

        render_success(CartItemSerializer.new(items).serializable_hash[:data])
      end

      def create
        item = current_customer_profile.cart_items
          .find_by(product_id: params[:product_id])

        if item
          item.quantity += params[:quantity].to_i
          if item.save
            render_success(CartItemSerializer.new(item).serializable_hash[:data])
          else
            render_validation_error(item)
          end
        else
          item = current_customer_profile.cart_items.build(
            product_id: params[:product_id],
            quantity: params[:quantity]
          )
          if item.save
            render_created(CartItemSerializer.new(item).serializable_hash[:data])
          else
            render_validation_error(item)
          end
        end
      end

      def update
        item = current_customer_profile.cart_items.find(params[:id])

        if item.update(quantity: params[:quantity])
          render_success(CartItemSerializer.new(item).serializable_hash[:data])
        else
          render_validation_error(item)
        end
      end

      def destroy
        item = current_customer_profile.cart_items.find(params[:id])
        item.destroy!

        render_success({ message: "Item removed from cart" })
      end

      def sync
        items_params = params.permit(items: [ :product_id, :quantity ])[:items] || []

        items_params.each do |item_data|
          existing = current_customer_profile.cart_items
            .find_by(product_id: item_data[:product_id])

          if existing
            existing.update!(quantity: existing.quantity + item_data[:quantity].to_i)
          else
            current_customer_profile.cart_items.create!(
              product_id: item_data[:product_id],
              quantity: item_data[:quantity]
            )
          end
        end

        items = current_customer_profile.cart_items
          .includes(product: [ :images, :inventory ])

        render_success(CartItemSerializer.new(items).serializable_hash[:data])
      end
    end
  end
end
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/cart_spec.rb`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add app/controllers/api/v1/cart_controller.rb app/serializers/cart_item_serializer.rb spec/requests/api/v1/cart_spec.rb config/routes.rb
git commit -m "feat: add Cart API (CRUD + sync)

GET /api/v1/cart — list cart items
POST /api/v1/cart/items — add to cart (increments if exists)
PATCH /api/v1/cart/items/:id — update quantity
DELETE /api/v1/cart/items/:id — remove from cart
POST /api/v1/cart/sync — merge guest local cart into server cart"
```

---

## Task 4: Wishlist Controller

**Files:**
- Create: `app/serializers/wishlist_item_serializer.rb`
- Create: `app/controllers/api/v1/wishlist_controller.rb`
- Create: `spec/requests/api/v1/wishlist_spec.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Create WishlistItemSerializer**

Create `app/serializers/wishlist_item_serializer.rb`:

```ruby
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
```

- [ ] **Step 2: Add wishlist routes**

In `config/routes.rb`, inside `namespace :v1`, add:

```ruby
      resource :wishlist, only: [ :show ], controller: "wishlist" do
        resources :items, only: [ :create, :destroy ], controller: "wishlist", as: :wishlist_items
      end
```

- [ ] **Step 3: Write request specs**

Create `spec/requests/api/v1/wishlist_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Wishlist", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "GET /api/v1/wishlist" do
    it "returns 401 without authentication" do
      get "/api/v1/wishlist"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns wishlist items" do
      product = create(:product, :with_inventory)
      create(:wishlist_item, customer_profile: profile, product: product)

      authenticated_get "/api/v1/wishlist", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end
  end

  describe "POST /api/v1/wishlist/items" do
    it "adds product to wishlist" do
      product = create(:product)

      authenticated_post "/api/v1/wishlist/items",
        customer_profile: profile,
        params: { product_id: product.id }

      expect(response).to have_http_status(:created)
      expect(profile.wishlist_items.count).to eq(1)
    end

    it "returns 409 if product already in wishlist" do
      product = create(:product)
      create(:wishlist_item, customer_profile: profile, product: product)

      authenticated_post "/api/v1/wishlist/items",
        customer_profile: profile,
        params: { product_id: product.id }

      expect(response).to have_http_status(:conflict)
    end
  end

  describe "DELETE /api/v1/wishlist/items/:id" do
    it "removes product from wishlist" do
      item = create(:wishlist_item, customer_profile: profile)

      authenticated_delete "/api/v1/wishlist/items/#{item.id}", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(profile.wishlist_items.count).to eq(0)
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/wishlist_spec.rb`

- [ ] **Step 5: Implement WishlistController**

Create `app/controllers/api/v1/wishlist_controller.rb`:

```ruby
module Api
  module V1
    class WishlistController < BaseController
      before_action :authenticate!

      def show
        items = current_customer_profile.wishlist_items
          .includes(product: [ :images, :inventory ])
          .order(created_at: :desc)

        render_success(WishlistItemSerializer.new(items).serializable_hash[:data])
      end

      def create
        item = current_customer_profile.wishlist_items.build(
          product_id: params[:product_id]
        )

        if item.save
          render_created(WishlistItemSerializer.new(item).serializable_hash[:data])
        elsif item.errors[:product_id]&.include?("has already been taken")
          render_error(
            code: "already_exists",
            message: "Product is already in your wishlist",
            status: :conflict
          )
        else
          render_validation_error(item)
        end
      end

      def destroy
        item = current_customer_profile.wishlist_items.find(params[:id])
        item.destroy!

        render_success({ message: "Item removed from wishlist" })
      end
    end
  end
end
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/wishlist_spec.rb`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add app/controllers/api/v1/wishlist_controller.rb app/serializers/wishlist_item_serializer.rb spec/requests/api/v1/wishlist_spec.rb config/routes.rb
git commit -m "feat: add Wishlist API (list, add, remove)

GET /api/v1/wishlist — list wishlist items
POST /api/v1/wishlist/items — add to wishlist (409 if duplicate)
DELETE /api/v1/wishlist/items/:id — remove from wishlist"
```

---

## Task 5: Profile Controller

**Files:**
- Create: `app/serializers/profile_serializer.rb`
- Create: `app/controllers/api/v1/profile_controller.rb`
- Create: `spec/requests/api/v1/profile_spec.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Create ProfileSerializer**

Create `app/serializers/profile_serializer.rb`:

```ruby
class ProfileSerializer
  include JSONAPI::Serializer

  attributes :auth_user_id, :phone, :birth_date, :created_at, :updated_at
end
```

- [ ] **Step 2: Add profile route**

In `config/routes.rb`, inside `namespace :v1`, add:

```ruby
      resource :profile, only: [ :show, :update ], controller: "profile"
```

- [ ] **Step 3: Write request specs**

Create `spec/requests/api/v1/profile_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Profile", type: :request do
  let(:profile) { create(:customer_profile, phone: "+52 55 1234 5678") }

  describe "GET /api/v1/profile" do
    it "returns 401 without authentication" do
      get "/api/v1/profile"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the current user profile" do
      authenticated_get "/api/v1/profile", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data[:attributes][:phone]).to eq("+52 55 1234 5678")
    end

    it "auto-creates profile on first request" do
      new_profile = build(:customer_profile)

      authenticated_get "/api/v1/profile", customer_profile: new_profile

      expect(response).to have_http_status(:ok)
      expect(CustomerProfile.find_by(auth_user_id: new_profile.auth_user_id)).to be_present
    end
  end

  describe "PATCH /api/v1/profile" do
    it "updates profile fields" do
      authenticated_patch "/api/v1/profile",
        customer_profile: profile,
        params: { phone: "+52 55 9876 5432", birth_date: "1990-05-15" }

      expect(response).to have_http_status(:ok)
      expect(profile.reload.phone).to eq("+52 55 9876 5432")
      expect(profile.reload.birth_date).to eq(Date.new(1990, 5, 15))
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/profile_spec.rb`

- [ ] **Step 5: Implement ProfileController**

Create `app/controllers/api/v1/profile_controller.rb`:

```ruby
module Api
  module V1
    class ProfileController < BaseController
      before_action :authenticate!

      def show
        render_success(ProfileSerializer.new(current_customer_profile).serializable_hash[:data])
      end

      def update
        if current_customer_profile.update(profile_params)
          render_success(ProfileSerializer.new(current_customer_profile).serializable_hash[:data])
        else
          render_validation_error(current_customer_profile)
        end
      end

      private

      def profile_params
        params.permit(:phone, :birth_date)
      end
    end
  end
end
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/profile_spec.rb`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add app/controllers/api/v1/profile_controller.rb app/serializers/profile_serializer.rb spec/requests/api/v1/profile_spec.rb config/routes.rb
git commit -m "feat: add Profile API (read, update)

GET /api/v1/profile — current user profile (auto-created)
PATCH /api/v1/profile — update phone, birth_date"
```

---

## Task 6: Addresses Controller

**Files:**
- Create: `app/serializers/address_serializer.rb`
- Create: `app/controllers/api/v1/addresses_controller.rb`
- Create: `spec/requests/api/v1/addresses_spec.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Create AddressSerializer**

Create `app/serializers/address_serializer.rb`:

```ruby
class AddressSerializer
  include JSONAPI::Serializer

  attributes :label, :street, :city, :state, :zip_code, :country, :is_default
end
```

- [ ] **Step 2: Add addresses route**

In `config/routes.rb`, inside `namespace :v1`, add:

```ruby
      resources :addresses, only: [ :index, :create, :update, :destroy ]
```

- [ ] **Step 3: Write request specs**

Create `spec/requests/api/v1/addresses_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Addresses", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "GET /api/v1/addresses" do
    it "returns 401 without authentication" do
      get "/api/v1/addresses"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns user addresses" do
      create(:address, customer_profile: profile)

      authenticated_get "/api/v1/addresses", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end

    it "does not return other users addresses" do
      other = create(:customer_profile)
      create(:address, customer_profile: other)

      authenticated_get "/api/v1/addresses", customer_profile: profile

      expect(json_data).to be_empty
    end
  end

  describe "POST /api/v1/addresses" do
    it "creates a new address" do
      authenticated_post "/api/v1/addresses",
        customer_profile: profile,
        params: {
          label: "Home",
          street: "Av. Reforma 123",
          city: "CDMX",
          state: "Ciudad de México",
          zip_code: "06600",
          country: "MX"
        }

      expect(response).to have_http_status(:created)
      expect(profile.addresses.count).to eq(1)
    end

    it "returns 422 for missing required fields" do
      authenticated_post "/api/v1/addresses",
        customer_profile: profile,
        params: { label: "Home" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/addresses/:id" do
    it "updates an address" do
      address = create(:address, customer_profile: profile, city: "Guadalajara")

      authenticated_patch "/api/v1/addresses/#{address.id}",
        customer_profile: profile,
        params: { city: "Monterrey" }

      expect(response).to have_http_status(:ok)
      expect(address.reload.city).to eq("Monterrey")
    end
  end

  describe "DELETE /api/v1/addresses/:id" do
    it "deletes an address" do
      address = create(:address, customer_profile: profile)

      authenticated_delete "/api/v1/addresses/#{address.id}", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(profile.addresses.count).to eq(0)
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/addresses_spec.rb`

- [ ] **Step 5: Implement AddressesController**

Create `app/controllers/api/v1/addresses_controller.rb`:

```ruby
module Api
  module V1
    class AddressesController < BaseController
      before_action :authenticate!

      def index
        addresses = current_customer_profile.addresses.order(created_at: :desc)

        render_success(AddressSerializer.new(addresses).serializable_hash[:data])
      end

      def create
        address = current_customer_profile.addresses.build(address_params)

        if address.save
          render_created(AddressSerializer.new(address).serializable_hash[:data])
        else
          render_validation_error(address)
        end
      end

      def update
        address = current_customer_profile.addresses.find(params[:id])

        if address.update(address_params)
          render_success(AddressSerializer.new(address).serializable_hash[:data])
        else
          render_validation_error(address)
        end
      end

      def destroy
        address = current_customer_profile.addresses.find(params[:id])
        address.destroy!

        render_success({ message: "Address deleted" })
      end

      private

      def address_params
        params.permit(:label, :street, :city, :state, :zip_code, :country, :is_default)
      end
    end
  end
end
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/addresses_spec.rb`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add app/controllers/api/v1/addresses_controller.rb app/serializers/address_serializer.rb spec/requests/api/v1/addresses_spec.rb config/routes.rb
git commit -m "feat: add Addresses API (CRUD)

GET /api/v1/addresses — list user addresses
POST /api/v1/addresses — create address
PATCH /api/v1/addresses/:id — update address
DELETE /api/v1/addresses/:id — hard delete (safe due to order snapshots)"
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
Expected: All cart, wishlist, profile, and address routes listed correctly.
