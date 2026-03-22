# Module 2B: Data Model — Commerce Models Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create all commerce-related models (addresses, cart_items, wishlist_items, reviews, orders, order_items, payments, shipments) with validations, associations, AASM state machines, and factory definitions.

**Architecture:** All user-linked tables reference `customer_profile_id`. Orders and shipments use AASM for state machines. Order snapshots preserve historical data at creation time.

**Tech Stack:** Rails 8.1, ActiveRecord, AASM, FactoryBot, Faker, RSpec

**Spec reference:** `craftitapp/docs/superpowers/specs/2026-03-21-backend-architecture-design.md` — Data Model section

**Depends on:** Module 2A (Core Models) must be completed first.

---

## File Structure

```
craftit-api/
├── db/migrate/
│   ├── XXXXXX_create_addresses.rb
│   ├── XXXXXX_create_cart_items.rb
│   ├── XXXXXX_create_wishlist_items.rb
│   ├── XXXXXX_create_reviews.rb
│   ├── XXXXXX_create_orders.rb
│   ├── XXXXXX_create_order_items.rb
│   ├── XXXXXX_create_payments.rb
│   └── XXXXXX_create_shipments.rb
├── app/models/
│   ├── address.rb
│   ├── cart_item.rb
│   ├── wishlist_item.rb
│   ├── review.rb
│   ├── order.rb
│   ├── order_item.rb
│   ├── payment.rb
│   └── shipment.rb
├── spec/
│   ├── models/ (one spec per model)
│   └── factories/ (one factory per model)
```

---

## Task 1: Address Model

**Files:**
- Create via generator: migration, model, spec, factory

- [ ] **Step 1: Generate model**

Run: `rails generate model Address customer_profile:references label:string street:string city:string state:string zip_code:string country:string is_default:boolean`

- [ ] **Step 2: Customize the migration**

```ruby
class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :customer_profile, null: false, foreign_key: true
      t.string :label
      t.string :street, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip_code, null: false
      t.string :country, null: false, default: "MX"
      t.boolean :is_default, default: false, null: false

      t.timestamps
    end
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`

- [ ] **Step 4: Write model spec**

Replace `spec/models/address_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe Address, type: :model do
  describe "validations" do
    subject { build(:address) }

    it { is_expected.to be_valid }

    %i[street city state zip_code country].each do |field|
      it "requires #{field}" do
        subject.send(:"#{field}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end

  describe "associations" do
    it "belongs to customer_profile" do
      profile = create(:customer_profile)
      address = create(:address, customer_profile: profile)
      expect(address.customer_profile).to eq(profile)
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/address_spec.rb`
Expected: FAIL

- [ ] **Step 6: Implement model**

Replace `app/models/address.rb`:

```ruby
class Address < ApplicationRecord
  belongs_to :customer_profile

  validates :street, :city, :state, :zip_code, :country, presence: true
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/addresses.rb`:

```ruby
FactoryBot.define do
  factory :address do
    association :customer_profile
    label { %w[Home Work Office].sample }
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip_code { Faker::Address.zip_code }
    country { "MX" }
    is_default { false }

    trait :default do
      is_default { true }
    end
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/address_spec.rb`
Expected: PASS

- [ ] **Step 9: Add association to CustomerProfile**

In `app/models/customer_profile.rb`, add:

```ruby
  has_many :addresses, dependent: :destroy
```

- [ ] **Step 10: Commit**

```bash
git add db/migrate/ app/models/address.rb app/models/customer_profile.rb spec/models/address_spec.rb spec/factories/addresses.rb db/schema.rb
git commit -m "feat: add Address model

Belongs to CustomerProfile. Required fields for Mexican addresses.
Defaults country to MX."
```

---

## Task 2: CartItem Model

**Files:**
- Create via generator: migration, model, spec, factory

- [ ] **Step 1: Generate model**

Run: `rails generate model CartItem customer_profile:references product:references quantity:integer`

- [ ] **Step 2: Customize the migration**

```ruby
class CreateCartItems < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_items do |t|
      t.references :customer_profile, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :cart_items, :customer_profile_id
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`

- [ ] **Step 4: Write model spec**

Replace `spec/models/cart_item_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe CartItem, type: :model do
  describe "validations" do
    subject { build(:cart_item) }

    it { is_expected.to be_valid }

    it "requires quantity greater than 0" do
      subject.quantity = 0
      expect(subject).not_to be_valid
    end

    it "requires integer quantity" do
      subject.quantity = 1.5
      expect(subject).not_to be_valid
    end
  end

  describe "#subtotal" do
    it "calculates quantity times product price" do
      product = create(:product, price: 299.99)
      cart_item = build(:cart_item, product: product, quantity: 2)
      expect(cart_item.subtotal).to eq(599.98)
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/cart_item_spec.rb`

- [ ] **Step 6: Implement model**

Replace `app/models/cart_item.rb`:

```ruby
class CartItem < ApplicationRecord
  belongs_to :customer_profile
  belongs_to :product

  validates :quantity, presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  def subtotal
    product.price * quantity
  end
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/cart_items.rb`:

```ruby
FactoryBot.define do
  factory :cart_item do
    association :customer_profile
    association :product
    quantity { Faker::Number.between(from: 1, to: 5) }
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/cart_item_spec.rb`
Expected: PASS

- [ ] **Step 9: Add association to CustomerProfile**

In `app/models/customer_profile.rb`, add:

```ruby
  has_many :cart_items, dependent: :destroy
```

- [ ] **Step 10: Commit**

```bash
git add db/migrate/ app/models/cart_item.rb app/models/customer_profile.rb spec/models/cart_item_spec.rb spec/factories/cart_items.rb db/schema.rb
git commit -m "feat: add CartItem model with quantity validation

Belongs to CustomerProfile and Product. Subtotal helper
for price calculation."
```

---

## Task 3: WishlistItem Model

**Files:**
- Create via generator: migration, model, spec, factory

- [ ] **Step 1: Generate model**

Run: `rails generate model WishlistItem customer_profile:references product:references`

- [ ] **Step 2: Customize the migration**

```ruby
class CreateWishlistItems < ActiveRecord::Migration[8.1]
  def change
    create_table :wishlist_items do |t|
      t.references :customer_profile, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    add_index :wishlist_items, [ :customer_profile_id, :product_id ], unique: true
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`

- [ ] **Step 4: Write model spec**

Replace `spec/models/wishlist_item_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe WishlistItem, type: :model do
  describe "validations" do
    subject { build(:wishlist_item) }

    it { is_expected.to be_valid }

    it "prevents duplicate product in wishlist" do
      profile = create(:customer_profile)
      product = create(:product)
      create(:wishlist_item, customer_profile: profile, product: product)

      duplicate = build(:wishlist_item, customer_profile: profile, product: product)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:product_id]).to include("has already been taken")
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/wishlist_item_spec.rb`

- [ ] **Step 6: Implement model**

Replace `app/models/wishlist_item.rb`:

```ruby
class WishlistItem < ApplicationRecord
  belongs_to :customer_profile
  belongs_to :product

  validates :product_id, uniqueness: { scope: :customer_profile_id }
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/wishlist_items.rb`:

```ruby
FactoryBot.define do
  factory :wishlist_item do
    association :customer_profile
    association :product
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/wishlist_item_spec.rb`
Expected: PASS

- [ ] **Step 9: Add association to CustomerProfile**

In `app/models/customer_profile.rb`, add:

```ruby
  has_many :wishlist_items, dependent: :destroy
```

- [ ] **Step 10: Commit**

```bash
git add db/migrate/ app/models/wishlist_item.rb app/models/customer_profile.rb spec/models/wishlist_item_spec.rb spec/factories/wishlist_items.rb db/schema.rb
git commit -m "feat: add WishlistItem model with uniqueness constraint

Composite unique index prevents duplicate product in wishlist."
```

---

## Task 4: Review Model

**Files:**
- Create via generator: migration, model, spec, factory

- [ ] **Step 1: Generate model**

Run: `rails generate model Review customer_profile:references product:references rating:integer title:string body:text is_verified_purchase:boolean`

- [ ] **Step 2: Customize the migration**

```ruby
class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :customer_profile, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :rating, null: false
      t.string :title
      t.text :body
      t.boolean :is_verified_purchase, default: false, null: false

      t.timestamps
    end

    add_index :reviews, :product_id
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`

- [ ] **Step 4: Write model spec**

Replace `spec/models/review_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe Review, type: :model do
  describe "validations" do
    subject { build(:review) }

    it { is_expected.to be_valid }

    it "requires rating" do
      subject.rating = nil
      expect(subject).not_to be_valid
    end

    it "requires rating between 1 and 5" do
      subject.rating = 0
      expect(subject).not_to be_valid

      subject.rating = 6
      expect(subject).not_to be_valid

      subject.rating = 3
      expect(subject).to be_valid
    end

    it "requires integer rating" do
      subject.rating = 3.5
      expect(subject).not_to be_valid
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/review_spec.rb`

- [ ] **Step 6: Implement model**

Replace `app/models/review.rb`:

```ruby
class Review < ApplicationRecord
  belongs_to :customer_profile
  belongs_to :product

  validates :rating, presence: true,
    numericality: { only_integer: true, in: 1..5 }
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/reviews.rb`:

```ruby
FactoryBot.define do
  factory :review do
    association :customer_profile
    association :product
    rating { Faker::Number.between(from: 1, to: 5) }
    title { Faker::Lorem.sentence(word_count: 4) }
    body { Faker::Lorem.paragraph(sentence_count: 3) }
    is_verified_purchase { false }

    trait :verified do
      is_verified_purchase { true }
    end
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/review_spec.rb`
Expected: PASS

- [ ] **Step 9: Add association to CustomerProfile**

In `app/models/customer_profile.rb`, add:

```ruby
  has_many :reviews, dependent: :destroy
```

- [ ] **Step 10: Commit**

```bash
git add db/migrate/ app/models/review.rb app/models/customer_profile.rb spec/models/review_spec.rb spec/factories/reviews.rb db/schema.rb
git commit -m "feat: add Review model with rating validation 1-5

Immutable in v1 (no edit/delete endpoints). Supports
verified purchase flag."
```

---

## Task 5: Order Model with AASM State Machine

**Files:**
- Create via generator: migration, model, spec, factory

- [ ] **Step 1: Generate model**

Run: `rails generate model Order customer_profile:references order_number:string status:integer subtotal:decimal shipping_cost:decimal tax:decimal tax_rate_snapshot:decimal total:decimal customer_name_snapshot:string customer_email_snapshot:string shipping_address_snapshot:jsonb`

- [ ] **Step 2: Customize the migration**

```ruby
class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :customer_profile, null: false, foreign_key: true
      t.string :order_number, null: false
      t.integer :status, default: 0, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false
      t.decimal :shipping_cost, precision: 10, scale: 2, default: 0, null: false
      t.decimal :tax, precision: 10, scale: 2, default: 0, null: false
      t.decimal :tax_rate_snapshot, precision: 5, scale: 4, default: 0.16, null: false
      t.decimal :total, precision: 10, scale: 2, null: false
      t.string :customer_name_snapshot
      t.string :customer_email_snapshot
      t.jsonb :shipping_address_snapshot, default: {}

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, :customer_profile_id
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`

- [ ] **Step 4: Write model spec**

Replace `spec/models/order_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe Order, type: :model do
  describe "validations" do
    subject { build(:order) }

    it { is_expected.to be_valid }

    it "requires order_number" do
      subject.order_number = nil
      expect(subject).not_to be_valid
    end

    it "requires unique order_number" do
      create(:order, order_number: "CRA-20260322-0001")
      subject.order_number = "CRA-20260322-0001"
      expect(subject).not_to be_valid
    end

    it "requires subtotal" do
      subject.subtotal = nil
      expect(subject).not_to be_valid
    end

    it "requires total" do
      subject.total = nil
      expect(subject).not_to be_valid
    end
  end

  describe "AASM state machine" do
    subject { create(:order) }

    it "starts as pending" do
      expect(subject).to be_pending
    end

    it "transitions from pending to paid" do
      subject.pay!
      expect(subject).to be_paid
    end

    it "transitions from paid to processing" do
      subject.pay!
      subject.process!
      expect(subject).to be_processing
    end

    it "transitions from processing to shipped" do
      subject.pay!
      subject.process!
      subject.ship!
      expect(subject).to be_shipped
    end

    it "transitions from shipped to delivered" do
      subject.pay!
      subject.process!
      subject.ship!
      subject.deliver!
      expect(subject).to be_delivered
    end

    it "can cancel from pending" do
      subject.cancel!
      expect(subject).to be_cancelled
    end

    it "can cancel from paid" do
      subject.pay!
      subject.cancel!
      expect(subject).to be_cancelled
    end

    it "cannot cancel from delivered" do
      subject.pay!
      subject.process!
      subject.ship!
      subject.deliver!
      expect { subject.cancel! }.to raise_error(AASM::InvalidTransition)
    end
  end

  describe "associations" do
    it "has many order_items" do
      order = create(:order)
      item = create(:order_item, order: order)
      expect(order.order_items).to include(item)
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/order_spec.rb`

- [ ] **Step 6: Implement Order model with AASM**

Replace `app/models/order.rb`:

```ruby
class Order < ApplicationRecord
  include AASM

  belongs_to :customer_profile
  has_many :order_items, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_one :shipment, dependent: :destroy

  validates :order_number, presence: true, uniqueness: true
  validates :subtotal, :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_cost, :tax, numericality: { greater_than_or_equal_to: 0 }

  enum :status, {
    pending: 0,
    paid: 1,
    processing: 2,
    shipped: 3,
    delivered: 4,
    cancelled: 5
  }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :paid
    state :processing
    state :shipped
    state :delivered
    state :cancelled

    event :pay do
      transitions from: :pending, to: :paid
    end

    event :process do
      transitions from: :paid, to: :processing
    end

    event :ship do
      transitions from: :processing, to: :shipped
    end

    event :deliver do
      transitions from: :shipped, to: :delivered
    end

    event :cancel do
      transitions from: [ :pending, :paid, :processing ], to: :cancelled
    end
  end
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/orders.rb`:

```ruby
FactoryBot.define do
  factory :order do
    association :customer_profile
    order_number { "CRA-#{Date.current.strftime('%Y%m%d')}-#{format('%04d', Faker::Number.unique.between(from: 1, to: 9999))}" }
    status { :pending }
    subtotal { Faker::Commerce.price(range: 100..5000.0) }
    shipping_cost { Faker::Commerce.price(range: 50..200.0) }
    tax_rate_snapshot { 0.16 }
    tax { (subtotal * tax_rate_snapshot).round(2) }
    total { (subtotal + shipping_cost + tax).round(2) }
    customer_name_snapshot { Faker::Name.name }
    customer_email_snapshot { Faker::Internet.email }
    shipping_address_snapshot do
      {
        street: Faker::Address.street_address,
        city: Faker::Address.city,
        state: Faker::Address.state,
        zip_code: Faker::Address.zip_code,
        country: "MX"
      }
    end

    trait :paid do
      status { :paid }
    end

    trait :processing do
      status { :processing }
    end

    trait :shipped do
      status { :shipped }
    end

    trait :delivered do
      status { :delivered }
    end

    trait :cancelled do
      status { :cancelled }
    end
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/order_spec.rb`
Expected: PASS

- [ ] **Step 9: Add association to CustomerProfile**

In `app/models/customer_profile.rb`, add:

```ruby
  has_many :orders, dependent: :restrict_with_error
```

- [ ] **Step 10: Commit**

```bash
git add db/migrate/ app/models/order.rb app/models/customer_profile.rb spec/models/order_spec.rb spec/factories/orders.rb db/schema.rb
git commit -m "feat: add Order model with AASM state machine

States: pending → paid → processing → shipped → delivered.
Cancellation from pending/paid/processing. Snapshots for
customer name, email, address, and tax rate."
```

---

## Task 6: OrderItem Model

**Files:**
- Create via generator: migration, model, spec, factory

- [ ] **Step 1: Generate model**

Run: `rails generate model OrderItem order:references product:references product_name_snapshot:string price_snapshot:decimal quantity:integer`

- [ ] **Step 2: Customize the migration**

```ruby
class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :product_name_snapshot, null: false
      t.decimal :price_snapshot, precision: 10, scale: 2, null: false
      t.integer :quantity, null: false

      t.timestamps
    end
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`

- [ ] **Step 4: Write model spec**

Replace `spec/models/order_item_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe OrderItem, type: :model do
  describe "validations" do
    subject { build(:order_item) }

    it { is_expected.to be_valid }

    it "requires quantity greater than 0" do
      subject.quantity = 0
      expect(subject).not_to be_valid
    end

    it "requires product_name_snapshot" do
      subject.product_name_snapshot = nil
      expect(subject).not_to be_valid
    end

    it "requires price_snapshot" do
      subject.price_snapshot = nil
      expect(subject).not_to be_valid
    end
  end

  describe "#subtotal" do
    it "calculates price_snapshot times quantity" do
      item = build(:order_item, price_snapshot: 299.99, quantity: 3)
      expect(item.subtotal).to eq(899.97)
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/order_item_spec.rb`

- [ ] **Step 6: Implement model**

Replace `app/models/order_item.rb`:

```ruby
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :product_name_snapshot, presence: true
  validates :price_snapshot, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  def subtotal
    price_snapshot * quantity
  end
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/order_items.rb`:

```ruby
FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    product_name_snapshot { Faker::Commerce.product_name }
    price_snapshot { Faker::Commerce.price(range: 100..2000.0) }
    quantity { Faker::Number.between(from: 1, to: 5) }
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/order_item_spec.rb`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
git add db/migrate/ app/models/order_item.rb spec/models/order_item_spec.rb spec/factories/order_items.rb db/schema.rb
git commit -m "feat: add OrderItem model with price snapshots

Stores product name and price at order time for immutable
historical records. Subtotal helper for line item totals."
```

---

## Task 7: Payment Model

**Files:**
- Create via generator: migration, model, spec, factory

- [ ] **Step 1: Generate model**

Run: `rails generate model Payment order:references provider:string provider_payment_id:string status:integer amount:decimal currency:string`

- [ ] **Step 2: Customize the migration**

```ruby
class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :provider_payment_id
      t.integer :status, default: 0, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: "MXN", null: false

      t.timestamps
    end
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`

- [ ] **Step 4: Write model spec**

Replace `spec/models/payment_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "validations" do
    subject { build(:payment) }

    it { is_expected.to be_valid }

    it "requires provider" do
      subject.provider = nil
      expect(subject).not_to be_valid
    end

    it "requires amount" do
      subject.amount = nil
      expect(subject).not_to be_valid
    end

    it "requires positive amount" do
      subject.amount = 0
      expect(subject).not_to be_valid
    end
  end

  describe "AASM state machine" do
    subject { create(:payment) }

    it "starts as pending" do
      expect(subject).to be_pending
    end

    it "transitions to completed" do
      subject.complete!
      expect(subject).to be_completed
    end

    it "transitions to failed" do
      subject.fail_payment!
      expect(subject).to be_failed
    end

    it "transitions from completed to refunded" do
      subject.complete!
      subject.refund!
      expect(subject).to be_refunded
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/payment_spec.rb`

- [ ] **Step 6: Implement model**

Replace `app/models/payment.rb`:

```ruby
class Payment < ApplicationRecord
  include AASM

  belongs_to :order

  validates :provider, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true

  enum :status, {
    pending: 0,
    completed: 1,
    failed: 2,
    refunded: 3
  }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :completed
    state :failed
    state :refunded

    event :complete do
      transitions from: :pending, to: :completed
    end

    event :fail_payment do
      transitions from: :pending, to: :failed
    end

    event :refund do
      transitions from: :completed, to: :refunded
    end
  end
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/payments.rb`:

```ruby
FactoryBot.define do
  factory :payment do
    association :order
    provider { "mercadopago" }
    provider_payment_id { nil }
    status { :pending }
    amount { Faker::Commerce.price(range: 100..5000.0) }
    currency { "MXN" }

    trait :completed do
      status { :completed }
      provider_payment_id { "MP-#{SecureRandom.hex(8)}" }
    end

    trait :failed do
      status { :failed }
    end

    trait :refunded do
      status { :refunded }
      provider_payment_id { "MP-#{SecureRandom.hex(8)}" }
    end
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/payment_spec.rb`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
git add db/migrate/ app/models/payment.rb spec/models/payment_spec.rb spec/factories/payments.rb db/schema.rb
git commit -m "feat: add Payment model with AASM state machine

States: pending → completed/failed, completed → refunded.
Tracks MercadoPago provider and payment ID. Currency defaults to MXN."
```

---

## Task 8: Shipment Model

**Files:**
- Create via generator: migration, model, spec, factory

- [ ] **Step 1: Generate model**

Run: `rails generate model Shipment order:references carrier:string tracking_number:string tracking_url:string status:integer estimated_delivery:date`

- [ ] **Step 2: Customize the migration**

```ruby
class CreateShipments < ActiveRecord::Migration[8.1]
  def change
    create_table :shipments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :carrier
      t.string :tracking_number
      t.string :tracking_url
      t.integer :status, default: 0, null: false
      t.date :estimated_delivery

      t.timestamps
    end
  end
end
```

- [ ] **Step 3: Run migration**

Run: `rails db:migrate`

- [ ] **Step 4: Write model spec**

Replace `spec/models/shipment_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe Shipment, type: :model do
  describe "AASM state machine" do
    subject { create(:shipment) }

    it "starts as preparing" do
      expect(subject).to be_preparing
    end

    it "transitions to shipped" do
      subject.ship!
      expect(subject).to be_shipped
    end

    it "transitions to in_transit" do
      subject.ship!
      subject.in_transit!
      expect(subject).to be_in_transit
    end

    it "transitions to delivered" do
      subject.ship!
      subject.in_transit!
      subject.deliver!
      expect(subject).to be_delivered
    end
  end
end
```

- [ ] **Step 5: Run test to verify it fails**

Run: `bundle exec rspec spec/models/shipment_spec.rb`

- [ ] **Step 6: Implement model**

Replace `app/models/shipment.rb`:

```ruby
class Shipment < ApplicationRecord
  include AASM

  belongs_to :order

  enum :status, {
    preparing: 0,
    shipped: 1,
    in_transit: 2,
    delivered: 3
  }

  aasm column: :status, enum: true do
    state :preparing, initial: true
    state :shipped
    state :in_transit
    state :delivered

    event :ship do
      transitions from: :preparing, to: :shipped
    end

    event :in_transit do
      transitions from: :shipped, to: :in_transit
    end

    event :deliver do
      transitions from: [ :shipped, :in_transit ], to: :delivered
    end
  end
end
```

- [ ] **Step 7: Customize factory**

Replace `spec/factories/shipments.rb`:

```ruby
FactoryBot.define do
  factory :shipment do
    association :order
    carrier { %w[DHL FedEx Estafeta].sample }
    tracking_number { SecureRandom.hex(8).upcase }
    tracking_url { "https://tracking.example.com/#{tracking_number}" }
    status { :preparing }
    estimated_delivery { Faker::Date.forward(days: 7) }
  end
end
```

- [ ] **Step 8: Run test to verify it passes**

Run: `bundle exec rspec spec/models/shipment_spec.rb`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
git add db/migrate/ app/models/shipment.rb spec/models/shipment_spec.rb spec/factories/shipments.rb db/schema.rb
git commit -m "feat: add Shipment model with AASM state machine

States: preparing → shipped → in_transit → delivered.
Tracks carrier, tracking number, URL, and estimated delivery."
```

---

## Task 9: Final Associations and Full Suite Verification

- [ ] **Step 1: Verify all CustomerProfile associations are complete**

`app/models/customer_profile.rb` should have:

```ruby
class CustomerProfile < ApplicationRecord
  validates :auth_user_id, presence: true, uniqueness: true

  has_many :addresses, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
end
```

- [ ] **Step 2: Run full test suite**

Run: `bundle exec rspec --format documentation`
Expected: All specs pass.

- [ ] **Step 3: Run RuboCop**

Run: `bundle exec rubocop`
Expected: No offenses (or auto-correct with `bundle exec rubocop -A`).

- [ ] **Step 4: Annotate all models**

Run: `bundle exec annotate --models`
Expected: Schema comments added to all model files.

- [ ] **Step 5: Commit annotations and any fixes**

```bash
git add app/models/ spec/
git commit -m "chore: annotate all models and finalize associations"
```

---

## Task 10: Seed Data

**Files:**
- Modify: `db/seeds.rb`

- [ ] **Step 1: Create seed data**

Replace `db/seeds.rb`:

```ruby
# Clear existing data in development
if Rails.env.development?
  puts "Clearing existing data..."
  [OrderItem, Order, Payment, Shipment, CartItem, WishlistItem, Review, Inventory, ProductImage, Product, Category, Address, CustomerProfile].each(&:destroy_all)
end

puts "Seeding categories..."
figures = Category.create!(name: "Figures", description: "Action figures and collectibles")
anime = Category.create!(name: "Anime", parent_category: figures, description: "Anime figures")
manga = Category.create!(name: "Manga", description: "Manga books and volumes")
board_games = Category.create!(name: "Board Games", description: "Tabletop and board games")

puts "Seeding products..."
products = [
  { name: "Goku Ultra Instinct Figure", price: 899.99, sku: "FIG-DBZ-001", category: anime, description: "High-quality Dragon Ball figure" },
  { name: "Naruto Sage Mode Figure", price: 749.99, sku: "FIG-NAR-001", category: anime, description: "Detailed Naruto Shippuden figure" },
  { name: "One Piece Vol. 1", price: 129.99, sku: "MNG-OP-001", category: manga, description: "First volume of One Piece manga" },
  { name: "Catan Board Game", price: 599.99, sku: "BRD-CTN-001", category: board_games, description: "Classic strategy board game" },
  { name: "Attack on Titan Levi Figure", price: 1299.99, compare_at_price: 1599.99, sku: "FIG-AOT-001", category: anime, description: "Premium Levi Ackerman figure" }
]

products.each do |attrs|
  product = Product.create!(attrs)
  Inventory.create!(product: product, stock: rand(10..50), low_stock_threshold: 5)
  ProductImage.create!(product: product, url: "https://placehold.co/600x600?text=#{product.slug}", alt_text: product.name, position: 0)
end

puts "Seeding customer profile..."
profile = CustomerProfile.create!(auth_user_id: "seed-user-001", phone: "+52 55 1234 5678")
Address.create!(customer_profile: profile, label: "Home", street: "Av. Reforma 123", city: "CDMX", state: "Ciudad de México", zip_code: "06600", country: "MX", is_default: true)

puts "Done! Created #{Category.count} categories, #{Product.count} products, #{Inventory.count} inventories."
```

- [ ] **Step 2: Run seeds**

Run: `rails db:seed`
Expected: Seed data created without errors.

- [ ] **Step 3: Verify in console**

Run: `rails console -e development`
Then: `Product.count` → 5, `Category.count` → 4, `Inventory.count` → 5
Exit console.

- [ ] **Step 4: Commit**

```bash
git add db/seeds.rb
git commit -m "feat: add seed data for development

Seeds categories (with hierarchy), products, inventories,
product images, and a test customer profile with address."
```
