# Module 2A: Data Model — Core Models Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create all database migrations and core models (customer_profiles, categories, products, product_images, inventory) with validations, associations, slugs, and factory definitions.

**Architecture:** All tables live in the `public` schema. Models use ActiveRecord validations, FriendlyId for slugs, and FactoryBot for test data. Each model is generated via `rails generate model` to ensure correct file placement.

**Tech Stack:** Rails 8.1, ActiveRecord, FriendlyId, FactoryBot, Faker, RSpec

**Spec reference:** `craftitapp/docs/superpowers/specs/2026-03-21-backend-architecture-design.md` — Data Model section

**Depends on:** Module 1 (Rails Foundation) must be completed first.

---

## File Structure

```
craftit-api/
├── db/migrate/
│   ├── XXXXXX_create_customer_profiles.rb     # CREATE (via generator)
│   ├── XXXXXX_create_categories.rb            # CREATE (via generator)
│   ├── XXXXXX_create_products.rb              # CREATE (via generator)
│   ├── XXXXXX_create_product_images.rb        # CREATE (via generator)
│   └── XXXXXX_create_inventories.rb           # CREATE (via generator)
├── app/models/
│   ├── customer_profile.rb                    # CREATE (via generator, then customize)
│   ├── category.rb                            # CREATE (via generator, then customize)
│   ├── product.rb                             # CREATE (via generator, then customize)
│   ├── product_image.rb                       # CREATE (via generator, then customize)
│   └── inventory.rb                           # CREATE (via generator, then customize)
├── spec/
│   ├── models/
│   │   ├── customer_profile_spec.rb           # CREATE (via generator, then customize)
│   │   ├── category_spec.rb                   # CREATE (via generator, then customize)
│   │   ├── product_spec.rb                    # CREATE (via generator, then customize)
│   │   ├── product_image_spec.rb              # CREATE (via generator, then customize)
│   │   └── inventory_spec.rb                  # CREATE (via generator, then customize)
│   └── factories/
│       ├── customer_profiles.rb               # CREATE (via generator, then customize)
│       ├── categories.rb                      # CREATE (via generator, then customize)
│       ├── products.rb                        # CREATE (via generator, then customize)
│       ├── product_images.rb                  # CREATE (via generator, then customize)
│       └── inventories.rb                     # CREATE (via generator, then customize)
```

---

## Task 1: CustomerProfile Model

**Files:**
- Create: `db/migrate/XXXXXX_create_customer_profiles.rb` (via generator)
- Create: `app/models/customer_profile.rb` (via generator, then customize)
- Create: `spec/models/customer_profile_spec.rb`
- Create: `spec/factories/customer_profiles.rb`

- [ ] **Step 1: Generate model with Rails CLI**

Run: `rails generate model CustomerProfile auth_user_id:string phone:string birth_date:date`
Expected: Creates migration, model, spec, and factory files.

- [ ] **Step 2: Customize the migration**

Edit the generated migration file to add the unique index and null constraint:

```ruby
class CreateCustomerProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_profiles do |t|
      t.string :auth_user_id, null: false
      t.string :phone
      t.date :birth_date

      t.timestamps
    end

    add_index :customer_profiles, :auth_user_id, unique: true
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`
Expected: Migration runs successfully.

- [ ] **Step 4: Write model spec**

Replace `spec/models/customer_profile_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe CustomerProfile, type: :model do
  describe "validations" do
    subject { build(:customer_profile) }

    it { is_expected.to be_valid }

    it "requires auth_user_id" do
      subject.auth_user_id = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:auth_user_id]).to include("can't be blank")
    end

    it "requires unique auth_user_id" do
      create(:customer_profile, auth_user_id: "user-123")
      subject.auth_user_id = "user-123"
      expect(subject).not_to be_valid
      expect(subject.errors[:auth_user_id]).to include("has already been taken")
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/customer_profile_spec.rb`
Expected: FAIL — model has no validations yet.

- [ ] **Step 6: Add validations to model**

Replace `app/models/customer_profile.rb`:

```ruby
class CustomerProfile < ApplicationRecord
  validates :auth_user_id, presence: true, uniqueness: true
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/customer_profiles.rb`:

```ruby
FactoryBot.define do
  factory :customer_profile do
    auth_user_id { SecureRandom.uuid }
    phone { Faker::PhoneNumber.phone_number }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65) }
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/customer_profile_spec.rb`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
git add db/migrate/ app/models/customer_profile.rb spec/models/customer_profile_spec.rb spec/factories/customer_profiles.rb db/schema.rb
git commit -m "feat: add CustomerProfile model with validations

Bridge between Better Auth (auth_user_id) and Rails domain.
Unique index on auth_user_id for JWT lookup performance."
```

---

## Task 2: Category Model

**Files:**
- Create: `db/migrate/XXXXXX_create_categories.rb` (via generator)
- Create: `app/models/category.rb` (via generator, then customize)
- Create: `spec/models/category_spec.rb`
- Create: `spec/factories/categories.rb`

- [ ] **Step 1: Generate model**

Run: `rails generate model Category name:string slug:string description:text image_url:string parent_category_id:integer position:integer`
Expected: Creates migration, model, spec, and factory files.

- [ ] **Step 2: Customize the migration**

Edit the generated migration:

```ruby
class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :image_url
      t.references :parent_category, foreign_key: { to_table: :categories }, null: true
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :categories, :slug, unique: true
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`
Expected: Migration runs successfully.

- [ ] **Step 4: Write model spec**

Replace `spec/models/category_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe Category, type: :model do
  describe "validations" do
    subject { build(:category) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires unique slug" do
      create(:category, slug: "figures")
      subject.slug = "figures"
      expect(subject).not_to be_valid
    end
  end

  describe "associations" do
    it "can have a parent category" do
      parent = create(:category)
      child = create(:category, parent_category: parent)

      expect(child.parent_category).to eq(parent)
      expect(parent.subcategories).to include(child)
    end
  end

  describe "slugs" do
    it "generates slug from name" do
      category = create(:category, name: "Action Figures")
      expect(category.slug).to eq("action-figures")
    end

    it "finds by slug using friendly_id" do
      category = create(:category, name: "Board Games")
      found = Category.friendly.find("board-games")
      expect(found).to eq(category)
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/category_spec.rb`
Expected: FAIL — no validations, associations, or FriendlyId setup.

- [ ] **Step 6: Implement Category model**

Replace `app/models/category.rb`:

```ruby
class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :parent_category, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: :parent_category_id,
    dependent: :nullify, inverse_of: :parent_category

  has_many :products, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :top_level, -> { where(parent_category_id: nil) }
  scope :ordered, -> { order(:position, :name) }
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/categories.rb`:

```ruby
FactoryBot.define do
  factory :category do
    name { Faker::Commerce.department(max: 1) }
    slug { nil } # Let FriendlyId generate it
    description { Faker::Lorem.paragraph }
    image_url { Faker::Internet.url }
    position { Faker::Number.between(from: 0, to: 10) }

    trait :with_parent do
      association :parent_category, factory: :category
    end
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/category_spec.rb`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
git add db/migrate/ app/models/category.rb spec/models/category_spec.rb spec/factories/categories.rb db/schema.rb
git commit -m "feat: add Category model with FriendlyId slugs

Self-referential parent_category for hierarchical categories.
Scopes for top_level and ordered queries."
```

---

## Task 3: Product Model

**Files:**
- Create: `db/migrate/XXXXXX_create_products.rb` (via generator)
- Create: `app/models/product.rb` (via generator, then customize)
- Create: `spec/models/product_spec.rb`
- Create: `spec/factories/products.rb`

- [ ] **Step 1: Generate model**

Run: `rails generate model Product name:string slug:string description:text price:decimal compare_at_price:decimal sku:string category:references is_active:boolean is_featured:boolean`
Expected: Creates migration, model, spec, and factory files.

- [ ] **Step 2: Customize the migration**

Edit the generated migration:

```ruby
class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :compare_at_price, precision: 10, scale: 2
      t.string :sku, null: false
      t.references :category, foreign_key: true, null: true
      t.boolean :is_active, default: true, null: false
      t.boolean :is_featured, default: false, null: false

      t.timestamps
    end

    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true
    add_index :products, [ :category_id, :is_active ]
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`
Expected: Migration runs successfully.

- [ ] **Step 4: Write model spec**

Replace `spec/models/product_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe Product, type: :model do
  describe "validations" do
    subject { build(:product) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires price" do
      subject.price = nil
      expect(subject).not_to be_valid
    end

    it "requires price to be positive" do
      subject.price = -1
      expect(subject).not_to be_valid
    end

    it "requires sku" do
      subject.sku = nil
      expect(subject).not_to be_valid
    end

    it "requires unique sku" do
      create(:product, sku: "SKU-001")
      subject.sku = "SKU-001"
      expect(subject).not_to be_valid
    end

    it "requires unique slug" do
      create(:product, name: "Dragon Ball Figure", slug: "dragon-ball-figure")
      subject.slug = "dragon-ball-figure"
      expect(subject).not_to be_valid
    end

    it "allows compare_at_price to be nil" do
      subject.compare_at_price = nil
      expect(subject).to be_valid
    end

    it "requires compare_at_price to be positive when present" do
      subject.compare_at_price = -5
      expect(subject).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a category" do
      category = create(:category)
      product = create(:product, category: category)
      expect(product.category).to eq(category)
    end

    it "has many images" do
      product = create(:product)
      image = create(:product_image, product: product)
      expect(product.images).to include(image)
    end

    it "has one inventory" do
      product = create(:product)
      inventory = create(:inventory, product: product)
      expect(product.inventory).to eq(inventory)
    end
  end

  describe "slugs" do
    it "generates slug from name" do
      product = create(:product, name: "Naruto Shippuden Figure")
      expect(product.slug).to eq("naruto-shippuden-figure")
    end
  end

  describe "scopes" do
    it ".active returns only active products" do
      active = create(:product, is_active: true)
      create(:product, is_active: false)
      expect(Product.active).to eq([ active ])
    end

    it ".featured returns only featured products" do
      featured = create(:product, is_featured: true)
      create(:product, is_featured: false)
      expect(Product.featured).to eq([ featured ])
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/product_spec.rb`
Expected: FAIL — model has no validations, associations, or scopes.

- [ ] **Step 6: Implement Product model**

Replace `app/models/product.rb`:

```ruby
class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :category, optional: true
  has_many :images, class_name: "ProductImage", dependent: :destroy
  has_one :inventory, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :compare_at_price, numericality: { greater_than: 0 }, allow_nil: true

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :featured, -> { where(is_featured: true) }

  def available_stock
    inventory&.available_stock || 0
  end

  def in_stock?
    available_stock > 0
  end

  def on_sale?
    compare_at_price.present? && compare_at_price > price
  end
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/products.rb`:

```ruby
FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    slug { nil } # Let FriendlyId generate it
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    price { Faker::Commerce.price(range: 100..5000.0) }
    compare_at_price { nil }
    sku { "SKU-#{SecureRandom.hex(4).upcase}" }
    association :category
    is_active { true }
    is_featured { false }

    trait :inactive do
      is_active { false }
    end

    trait :featured do
      is_featured { true }
    end

    trait :on_sale do
      price { 299.99 }
      compare_at_price { 499.99 }
    end

    trait :with_inventory do
      after(:create) do |product|
        create(:inventory, product: product)
      end
    end
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/product_spec.rb`
Expected: PASS (some association tests may fail since ProductImage, Inventory models don't exist yet — that's expected, we'll fix after creating those models)

- [ ] **Step 9: Commit**

```bash
git add db/migrate/ app/models/product.rb spec/models/product_spec.rb spec/factories/products.rb db/schema.rb
git commit -m "feat: add Product model with FriendlyId, validations, scopes

Includes active/featured/on_sale scopes, available_stock helper,
and associations to category, images, inventory, reviews."
```

---

## Task 4: ProductImage Model

**Files:**
- Create: `db/migrate/XXXXXX_create_product_images.rb` (via generator)
- Create: `app/models/product_image.rb` (via generator, then customize)
- Create: `spec/models/product_image_spec.rb`
- Create: `spec/factories/product_images.rb`

- [ ] **Step 1: Generate model**

Run: `rails generate model ProductImage product:references url:string alt_text:string position:integer`
Expected: Creates migration, model, spec, and factory files.

- [ ] **Step 2: Customize the migration**

Edit the generated migration:

```ruby
class CreateProductImages < ActiveRecord::Migration[8.1]
  def change
    create_table :product_images do |t|
      t.references :product, null: false, foreign_key: true
      t.string :url, null: false
      t.string :alt_text
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`
Expected: Migration runs successfully.

- [ ] **Step 4: Write model spec**

Replace `spec/models/product_image_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe ProductImage, type: :model do
  describe "validations" do
    subject { build(:product_image) }

    it { is_expected.to be_valid }

    it "requires url" do
      subject.url = nil
      expect(subject).not_to be_valid
    end

    it "requires product" do
      subject.product = nil
      expect(subject).not_to be_valid
    end
  end

  describe "scopes" do
    it ".ordered returns images sorted by position" do
      product = create(:product)
      img2 = create(:product_image, product: product, position: 2)
      img1 = create(:product_image, product: product, position: 1)

      expect(ProductImage.ordered).to eq([ img1, img2 ])
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/product_image_spec.rb`
Expected: FAIL

- [ ] **Step 6: Implement ProductImage model**

Replace `app/models/product_image.rb`:

```ruby
class ProductImage < ApplicationRecord
  belongs_to :product

  validates :url, presence: true

  scope :ordered, -> { order(:position) }
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/product_images.rb`:

```ruby
FactoryBot.define do
  factory :product_image do
    association :product
    url { Faker::Internet.url(host: "supabase.co", path: "/storage/v1/#{SecureRandom.hex(8)}.jpg") }
    alt_text { Faker::Lorem.sentence(word_count: 3) }
    position { Faker::Number.between(from: 0, to: 5) }
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/product_image_spec.rb`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
git add db/migrate/ app/models/product_image.rb spec/models/product_image_spec.rb spec/factories/product_images.rb db/schema.rb
git commit -m "feat: add ProductImage model

Stores Supabase Storage URLs for product images.
Ordered scope for position-based display."
```

---

## Task 5: Inventory Model

**Files:**
- Create: `db/migrate/XXXXXX_create_inventories.rb` (via generator)
- Create: `app/models/inventory.rb` (via generator, then customize)
- Create: `spec/models/inventory_spec.rb`
- Create: `spec/factories/inventories.rb`

- [ ] **Step 1: Generate model**

Run: `rails generate model Inventory product:references stock:integer reserved_stock:integer low_stock_threshold:integer`
Expected: Creates migration, model, spec, and factory files.

- [ ] **Step 2: Customize the migration**

Edit the generated migration:

```ruby
class CreateInventories < ActiveRecord::Migration[8.1]
  def change
    create_table :inventories do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :stock, default: 0, null: false
      t.integer :reserved_stock, default: 0, null: false
      t.integer :low_stock_threshold, default: 5, null: false

      t.timestamps
    end

    add_index :inventories, :product_id, unique: true
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`
Expected: Migration runs successfully.

- [ ] **Step 4: Write model spec**

Replace `spec/models/inventory_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe Inventory, type: :model do
  describe "validations" do
    subject { build(:inventory) }

    it { is_expected.to be_valid }

    it "requires stock to be non-negative" do
      subject.stock = -1
      expect(subject).not_to be_valid
    end

    it "requires reserved_stock to be non-negative" do
      subject.reserved_stock = -1
      expect(subject).not_to be_valid
    end

    it "requires low_stock_threshold to be non-negative" do
      subject.low_stock_threshold = -1
      expect(subject).not_to be_valid
    end
  end

  describe "#available_stock" do
    it "returns stock minus reserved_stock" do
      inventory = build(:inventory, stock: 10, reserved_stock: 3)
      expect(inventory.available_stock).to eq(7)
    end
  end

  describe "#in_stock?" do
    it "returns true when available stock is positive" do
      inventory = build(:inventory, stock: 5, reserved_stock: 0)
      expect(inventory).to be_in_stock
    end

    it "returns false when all stock is reserved" do
      inventory = build(:inventory, stock: 5, reserved_stock: 5)
      expect(inventory).not_to be_in_stock
    end
  end

  describe "#low_stock?" do
    it "returns true when available stock is at or below threshold" do
      inventory = build(:inventory, stock: 5, reserved_stock: 0, low_stock_threshold: 5)
      expect(inventory).to be_low_stock
    end

    it "returns false when available stock is above threshold" do
      inventory = build(:inventory, stock: 10, reserved_stock: 0, low_stock_threshold: 5)
      expect(inventory).not_to be_low_stock
    end
  end

  describe "#sufficient_stock?" do
    it "returns true when enough available stock for quantity" do
      inventory = build(:inventory, stock: 10, reserved_stock: 3)
      expect(inventory.sufficient_stock?(5)).to be true
    end

    it "returns false when not enough available stock" do
      inventory = build(:inventory, stock: 10, reserved_stock: 8)
      expect(inventory.sufficient_stock?(5)).to be false
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/inventory_spec.rb`
Expected: FAIL

- [ ] **Step 6: Implement Inventory model**

Replace `app/models/inventory.rb`:

```ruby
class Inventory < ApplicationRecord
  belongs_to :product

  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_stock, numericality: { greater_than_or_equal_to: 0 }
  validates :low_stock_threshold, numericality: { greater_than_or_equal_to: 0 }

  scope :low_stock, -> { where("stock - reserved_stock <= low_stock_threshold") }

  def available_stock
    stock - reserved_stock
  end

  def in_stock?
    available_stock > 0
  end

  def low_stock?
    available_stock <= low_stock_threshold
  end

  def sufficient_stock?(quantity)
    available_stock >= quantity
  end
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/inventories.rb`:

```ruby
FactoryBot.define do
  factory :inventory do
    association :product
    stock { Faker::Number.between(from: 10, to: 100) }
    reserved_stock { 0 }
    low_stock_threshold { 5 }

    trait :low_stock do
      stock { 3 }
    end

    trait :out_of_stock do
      stock { 0 }
    end
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/inventory_spec.rb`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
git add db/migrate/ app/models/inventory.rb spec/models/inventory_spec.rb spec/factories/inventories.rb db/schema.rb
git commit -m "feat: add Inventory model with stock management

Separate from Product for clear responsibility. Tracks stock,
reserved_stock, and low_stock_threshold. Provides available_stock,
in_stock?, low_stock?, and sufficient_stock? helpers."
```

---

## Task 6: Run Full Suite and Verify All Associations

- [ ] **Step 1: Re-run all Product specs (associations should now pass)**

Run: `bundle exec rspec spec/models/product_spec.rb`
Expected: All tests pass now that ProductImage and Inventory exist.

- [ ] **Step 2: Run full test suite**

Run: `bundle exec rspec --format documentation`
Expected: All specs pass.

- [ ] **Step 3: Run RuboCop**

Run: `bundle exec rubocop`
Expected: No offenses (or auto-correct if needed with `bundle exec rubocop -A`).

- [ ] **Step 4: Annotate models**

Run: `bundle exec annotate --models`
Expected: Schema comments added to model files.

- [ ] **Step 5: Commit annotations**

```bash
git add app/models/
git commit -m "chore: annotate models with schema comments"
```
