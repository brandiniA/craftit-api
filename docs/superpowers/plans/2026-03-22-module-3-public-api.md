# Module 3: Public API — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build all public (no JWT) API endpoints: products listing/detail/search, categories listing/by-slug, and product reviews. These are the read-only endpoints that power the storefront for all visitors.

**Architecture:** Thin controllers delegate to ActiveRecord scopes. Serializers control JSON output. Pagy handles pagination. FriendlyId enables slug-based lookups. All responses use the consistent format from Module 1.

**Tech Stack:** Rails 8.1, jsonapi-serializer, Pagy, FriendlyId, RSpec request specs

**Spec reference:** `craftitapp/docs/superpowers/specs/2026-03-21-backend-architecture-design.md` — API Endpoints > Public

**Depends on:** Module 1 (Foundation) + Module 2A/2B (Data Model) must be completed first.

---

## File Structure

```
craftit-api/
├── app/
│   ├── controllers/api/v1/
│   │   ├── products_controller.rb             # CREATE
│   │   ├── categories_controller.rb           # CREATE
│   │   └── reviews_controller.rb              # CREATE (public read only)
│   └── serializers/
│       ├── product_serializer.rb              # CREATE
│       ├── product_detail_serializer.rb       # CREATE
│       ├── category_serializer.rb             # CREATE
│       └── review_serializer.rb               # CREATE
├── config/
│   └── routes.rb                              # MODIFY — add public resources
└── spec/
    └── requests/api/v1/
        ├── products_spec.rb                   # CREATE
        ├── categories_spec.rb                 # CREATE
        └── reviews_spec.rb                    # CREATE
```

---

## Task 1: Product Serializers

**Files:**
- Create: `app/serializers/product_serializer.rb`
- Create: `app/serializers/product_detail_serializer.rb`

- [ ] **Step 1: Create the serializers directory**

Run: `mkdir -p app/serializers`

- [ ] **Step 2: Create ProductSerializer (list view)**

Create `app/serializers/product_serializer.rb`:

```ruby
class ProductSerializer
  include JSONAPI::Serializer

  attributes :name, :slug, :price, :compare_at_price, :is_active, :is_featured

  attribute :category_name do |product|
    product.category&.name
  end

  attribute :primary_image_url do |product|
    product.images.ordered.first&.url
  end

  attribute :in_stock do |product|
    product.in_stock?
  end

  attribute :on_sale do |product|
    product.on_sale?
  end

  attribute :average_rating do |product|
    product.reviews.average(:rating)&.round(1)
  end

  attribute :review_count do |product|
    product.reviews.count
  end
end
```

- [ ] **Step 3: Create ProductDetailSerializer (detail view)**

Create `app/serializers/product_detail_serializer.rb`:

```ruby
class ProductDetailSerializer
  include JSONAPI::Serializer

  attributes :name, :slug, :description, :price, :compare_at_price,
    :sku, :is_active, :is_featured, :created_at

  attribute :category do |product|
    if product.category
      { id: product.category.id, name: product.category.name, slug: product.category.slug }
    end
  end

  attribute :images do |product|
    product.images.ordered.map do |img|
      { id: img.id, url: img.url, alt_text: img.alt_text, position: img.position }
    end
  end

  attribute :in_stock do |product|
    product.in_stock?
  end

  attribute :available_stock do |product|
    product.available_stock
  end

  attribute :on_sale do |product|
    product.on_sale?
  end

  attribute :average_rating do |product|
    product.reviews.average(:rating)&.round(1)
  end

  attribute :review_count do |product|
    product.reviews.count
  end
end
```

- [ ] **Step 4: Commit**

```bash
git add app/serializers/
git commit -m "feat: add Product serializers for list and detail views

ProductSerializer for listings (compact). ProductDetailSerializer
for detail pages (includes images, description, stock info)."
```

---

## Task 2: Products Controller — List and Detail

**Files:**
- Create: `app/controllers/api/v1/products_controller.rb`
- Create: `spec/requests/api/v1/products_spec.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Add products routes**

In `config/routes.rb`, inside the `namespace :api` > `namespace :v1` block, add:

```ruby
      resources :products, only: [ :index, :show ], param: :slug do
        get "reviews", to: "reviews#index", on: :member
      end

      get "products/search", to: "products#search", as: :products_search
```

Note: the `search` route must be defined **before** the `resources :products` line so it doesn't conflict with `:slug`. Reorder as:

```ruby
  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"

      get "products/search", to: "products#search"
      resources :products, only: [ :index, :show ], param: :slug do
        get "reviews", to: "reviews#index", on: :member
      end
    end
  end
```

- [ ] **Step 2: Write request specs for products**

Create `spec/requests/api/v1/products_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Products", type: :request do
  describe "GET /api/v1/products" do
    it "returns paginated active products" do
      create_list(:product, 3, :with_inventory, is_active: true)
      create(:product, is_active: false)

      get "/api/v1/products"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
      expect(json_response).to have_key(:meta)
      expect(json_response[:meta][:total_count]).to eq(3)
    end

    it "filters by category slug" do
      category = create(:category, slug: "anime")
      create(:product, :with_inventory, category: category)
      create(:product, :with_inventory)

      get "/api/v1/products", params: { category: "anime" }

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end

    it "filters featured products" do
      create(:product, :with_inventory, is_featured: true)
      create(:product, :with_inventory, is_featured: false)

      get "/api/v1/products", params: { featured: "true" }

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end
  end

  describe "GET /api/v1/products/:slug" do
    it "returns product detail by slug" do
      product = create(:product, :with_inventory, name: "Dragon Ball Figure")
      create(:product_image, product: product)

      get "/api/v1/products/#{product.slug}"

      expect(response).to have_http_status(:ok)
      data = json_data[:attributes]
      expect(data[:name]).to eq("Dragon Ball Figure")
      expect(data[:slug]).to eq("dragon-ball-figure")
      expect(data).to have_key(:images)
      expect(data).to have_key(:available_stock)
    end

    it "returns 404 for non-existent slug" do
      get "/api/v1/products/nonexistent"

      expect(response).to have_http_status(:not_found)
      expect(json_error[:code]).to eq("not_found")
    end
  end

  describe "GET /api/v1/products/search" do
    it "searches products by name" do
      create(:product, :with_inventory, name: "Dragon Ball Figure")
      create(:product, :with_inventory, name: "Naruto Figure")

      get "/api/v1/products/search", params: { q: "dragon" }

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end

    it "returns empty results for no match" do
      get "/api/v1/products/search", params: { q: "nonexistent" }

      expect(response).to have_http_status(:ok)
      expect(json_data).to be_empty
    end
  end
end
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/products_spec.rb`
Expected: FAIL — controller does not exist.

- [ ] **Step 4: Implement ProductsController**

Create `app/controllers/api/v1/products_controller.rb`:

```ruby
module Api
  module V1
    class ProductsController < BaseController
      def index
        products = Product.active.includes(:category, :images, :inventory, :reviews)

        products = products.where(category: Category.friendly.find(params[:category])) if params[:category].present?
        products = products.featured if params[:featured] == "true"

        pagy, records = pagy(products.order(created_at: :desc))

        render_success(
          ProductSerializer.new(records).serializable_hash[:data],
          meta: pagination_meta(pagy)
        )
      end

      def show
        product = Product.friendly.find(params[:slug])
        product = Product.includes(:category, :images, :inventory, :reviews).find(product.id)

        render_success(ProductDetailSerializer.new(product).serializable_hash[:data])
      end

      def search
        products = Product.active.includes(:category, :images, :inventory, :reviews)

        if params[:q].present?
          products = products.where("name ILIKE ?", "%#{params[:q]}%")
        end

        if params[:min_price].present?
          products = products.where("price >= ?", params[:min_price])
        end

        if params[:max_price].present?
          products = products.where("price <= ?", params[:max_price])
        end

        products = products.where(category: Category.friendly.find(params[:category])) if params[:category].present?

        pagy, records = pagy(products.order(created_at: :desc))

        render_success(
          ProductSerializer.new(records).serializable_hash[:data],
          meta: pagination_meta(pagy)
        )
      end
    end
  end
end
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/products_spec.rb`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app/controllers/api/v1/products_controller.rb spec/requests/api/v1/products_spec.rb config/routes.rb
git commit -m "feat: add public Products API (list, detail, search)

GET /api/v1/products — paginated, filterable by category/featured
GET /api/v1/products/:slug — detail with images and stock
GET /api/v1/products/search — search by name, price range, category"
```

---

## Task 3: Category Serializer and Controller

**Files:**
- Create: `app/serializers/category_serializer.rb`
- Create: `app/controllers/api/v1/categories_controller.rb`
- Create: `spec/requests/api/v1/categories_spec.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Create CategorySerializer**

Create `app/serializers/category_serializer.rb`:

```ruby
class CategorySerializer
  include JSONAPI::Serializer

  attributes :name, :slug, :description, :image_url, :position

  attribute :parent_category do |category|
    if category.parent_category
      { id: category.parent_category.id, name: category.parent_category.name, slug: category.parent_category.slug }
    end
  end

  attribute :subcategories do |category|
    category.subcategories.ordered.map do |sub|
      { id: sub.id, name: sub.name, slug: sub.slug, image_url: sub.image_url }
    end
  end

  attribute :product_count do |category|
    category.products.active.count
  end
end
```

- [ ] **Step 2: Add categories routes**

In `config/routes.rb`, inside `namespace :v1`, add:

```ruby
      resources :categories, only: [ :index, :show ], param: :slug
```

- [ ] **Step 3: Write request specs**

Create `spec/requests/api/v1/categories_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Categories", type: :request do
  describe "GET /api/v1/categories" do
    it "returns all top-level categories" do
      parent = create(:category)
      create(:category, :with_parent)

      get "/api/v1/categories"

      expect(response).to have_http_status(:ok)
      # Returns all categories, not just top-level
      expect(json_data.length).to be >= 1
    end
  end

  describe "GET /api/v1/categories/:slug" do
    it "returns category with its products" do
      category = create(:category, name: "Anime Figures")
      create(:product, :with_inventory, category: category)

      get "/api/v1/categories/#{category.slug}"

      expect(response).to have_http_status(:ok)
      data = json_data
      expect(data[:category][:attributes][:name]).to eq("Anime Figures")
      expect(data[:products].length).to eq(1)
    end

    it "returns 404 for non-existent slug" do
      get "/api/v1/categories/nonexistent"

      expect(response).to have_http_status(:not_found)
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/categories_spec.rb`

- [ ] **Step 5: Implement CategoriesController**

Create `app/controllers/api/v1/categories_controller.rb`:

```ruby
module Api
  module V1
    class CategoriesController < BaseController
      def index
        categories = Category.includes(:parent_category, :subcategories, :products)
          .ordered

        render_success(CategorySerializer.new(categories).serializable_hash[:data])
      end

      def show
        category = Category.friendly.find(params[:slug])
        products = category.products.active
          .includes(:images, :inventory, :reviews)
          .order(created_at: :desc)

        pagy, records = pagy(products)

        render_success(
          {
            category: CategorySerializer.new(category).serializable_hash[:data],
            products: ProductSerializer.new(records).serializable_hash[:data]
          },
          meta: pagination_meta(pagy)
        )
      end
    end
  end
end
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/categories_spec.rb`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add app/serializers/category_serializer.rb app/controllers/api/v1/categories_controller.rb spec/requests/api/v1/categories_spec.rb config/routes.rb
git commit -m "feat: add public Categories API (list, show with products)

GET /api/v1/categories — all categories with subcategories
GET /api/v1/categories/:slug — category detail with paginated products"
```

---

## Task 4: Review Serializer and Controller (Public Read)

**Files:**
- Create: `app/serializers/review_serializer.rb`
- Create: `app/controllers/api/v1/reviews_controller.rb`
- Create: `spec/requests/api/v1/reviews_spec.rb`

- [ ] **Step 1: Create ReviewSerializer**

Create `app/serializers/review_serializer.rb`:

```ruby
class ReviewSerializer
  include JSONAPI::Serializer

  attributes :rating, :title, :body, :is_verified_purchase, :created_at

  attribute :reviewer_name do |review|
    # Show first name only for privacy
    name = review.customer_profile&.auth_user_id&.first(8)
    "User #{name}"
  end
end
```

- [ ] **Step 2: Write request specs**

Create `spec/requests/api/v1/reviews_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Reviews", type: :request do
  describe "GET /api/v1/products/:slug/reviews" do
    it "returns paginated reviews for a product" do
      product = create(:product)
      create_list(:review, 3, product: product)

      get "/api/v1/products/#{product.slug}/reviews"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
    end

    it "returns 404 for non-existent product" do
      get "/api/v1/products/nonexistent/reviews"

      expect(response).to have_http_status(:not_found)
    end

    it "returns review summary in meta" do
      product = create(:product)
      create(:review, product: product, rating: 5)
      create(:review, product: product, rating: 3)

      get "/api/v1/products/#{product.slug}/reviews"

      expect(json_response[:meta][:average_rating]).to eq(4.0)
      expect(json_response[:meta][:total_count]).to eq(2)
    end
  end
end
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/reviews_spec.rb`

- [ ] **Step 4: Implement ReviewsController**

Create `app/controllers/api/v1/reviews_controller.rb`:

```ruby
module Api
  module V1
    class ReviewsController < BaseController
      def index
        product = Product.friendly.find(params[:id])
        reviews = product.reviews.includes(:customer_profile)
          .order(created_at: :desc)

        pagy, records = pagy(reviews)

        render_success(
          ReviewSerializer.new(records).serializable_hash[:data],
          meta: pagination_meta(pagy).merge(
            average_rating: product.reviews.average(:rating)&.round(1),
            total_count: product.reviews.count
          )
        )
      end
    end
  end
end
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/reviews_spec.rb`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app/serializers/review_serializer.rb app/controllers/api/v1/reviews_controller.rb spec/requests/api/v1/reviews_spec.rb
git commit -m "feat: add public Reviews API (product reviews listing)

GET /api/v1/products/:slug/reviews — paginated reviews with
average rating and total count in meta."
```

---

## Task 5: Final Verification

- [ ] **Step 1: Run full test suite**

Run: `bundle exec rspec --format documentation`
Expected: All specs pass.

- [ ] **Step 2: Run RuboCop**

Run: `bundle exec rubocop`
Expected: No offenses.

- [ ] **Step 3: Verify endpoints with curl (if server available)**

```bash
bin/rails server -p 3001 &
curl -s http://localhost:3001/api/v1/products | jq .
curl -s http://localhost:3001/api/v1/categories | jq .
curl -s http://localhost:3001/api/v1/products/search?q=dragon | jq .
kill %1
```

- [ ] **Step 4: Commit any remaining changes**

```bash
git status
# Review and commit if needed
```
