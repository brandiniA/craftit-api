# Module 5B: Payments & Webhooks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the payment flow endpoint (POST /api/v1/orders/:order_number/pay), MercadoPago webhook processing, and PaymentService. Also add the reservation timeout background job.

**Architecture:** PaymentService creates MercadoPago preferences and returns a payment URL. Webhooks are signature-verified server-to-server (no JWT). A background job cancels unpaid orders after 30 minutes and releases stock reservations.

**Tech Stack:** Rails 8.1, mercadopago-sdk (added when needed), Faraday, ActiveJob, RSpec

**Spec reference:** `craftitapp/docs/superpowers/specs/2026-03-21-backend-architecture-design.md` — Core Flows > Payment webhooks

**Depends on:** Modules 1-5A must be completed first.

**Note:** MercadoPago SDK integration is deferred until credentials are available. This plan stubs the external calls for testability and implements the full internal flow.

---

## File Structure

```
craftit-api/
├── app/
│   ├── controllers/api/v1/
│   │   ├── payments_controller.rb             # CREATE
│   │   └── webhooks_controller.rb             # CREATE
│   ├── services/
│   │   └── payment_service.rb                 # CREATE
│   └── jobs/
│       └── reservation_timeout_job.rb         # CREATE
├── config/
│   └── routes.rb                              # MODIFY
└── spec/
    ├── requests/api/v1/
    │   ├── payments_spec.rb                   # CREATE
    │   └── webhooks_spec.rb                   # CREATE
    ├── services/
    │   └── payment_service_spec.rb            # CREATE
    └── jobs/
        └── reservation_timeout_job_spec.rb    # CREATE
```

---

## Task 1: PaymentService

**Files:**
- Create: `app/services/payment_service.rb`
- Create: `spec/services/payment_service_spec.rb`

- [ ] **Step 1: Write service spec**

Create `spec/services/payment_service_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe PaymentService do
  describe ".create_payment!" do
    it "creates a pending payment record" do
      order = create(:order, total: 1500.00)

      payment = PaymentService.create_payment!(order)

      expect(payment).to be_pending
      expect(payment.provider).to eq("mercadopago")
      expect(payment.amount).to eq(1500.00)
      expect(payment.currency).to eq("MXN")
    end

    it "returns a payment URL" do
      order = create(:order, total: 1500.00)

      payment = PaymentService.create_payment!(order)

      expect(payment).to respond_to(:payment_url)
    end
  end

  describe ".process_webhook!" do
    it "completes payment and transitions order to processing" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: nil)
      product = create(:product)
      create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      PaymentService.process_webhook!(
        provider_payment_id: "MP-ABC123",
        status: "approved",
        order: order
      )

      expect(payment.reload).to be_completed
      expect(payment.provider_payment_id).to eq("MP-ABC123")
      expect(order.reload).to be_processing
    end

    it "marks payment as failed for rejected status" do
      order = create(:order, :pending)
      create(:payment, order: order)

      PaymentService.process_webhook!(
        provider_payment_id: "MP-ABC123",
        status: "rejected",
        order: order
      )

      expect(order.payment.reload).to be_failed
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/services/payment_service_spec.rb`

- [ ] **Step 3: Implement PaymentService**

Create `app/services/payment_service.rb`:

```ruby
class PaymentService
  # TODO: Replace with real MercadoPago SDK when credentials are available
  MOCK_PAYMENT_URL = "https://www.mercadopago.com.mx/checkout/v1/redirect".freeze

  def self.create_payment!(order)
    payment = order.create_payment!(
      provider: "mercadopago",
      amount: order.total,
      currency: "MXN"
    )

    # TODO: Create MercadoPago preference and get real payment URL
    # preference = MercadoPago::Preference.create(...)
    # payment.update!(provider_payment_id: preference.id)

    # For now, add a virtual attribute for the payment URL
    payment.define_singleton_method(:payment_url) do
      "#{MOCK_PAYMENT_URL}?preference_id=mock_#{payment.id}"
    end

    payment
  end

  def self.process_webhook!(provider_payment_id:, status:, order:)
    payment = order.payment
    return unless payment

    ActiveRecord::Base.transaction do
      payment.update!(provider_payment_id: provider_payment_id)

      case status
      when "approved"
        payment.complete!
        order.pay! if order.may_pay?
        order.process! if order.may_process?

        # Confirm inventory (deduct stock, release reservation)
        order.order_items.includes(product: :inventory).each do |item|
          InventoryService.confirm!(item.product.inventory, item.quantity)
        end
      when "rejected", "cancelled"
        payment.fail_payment!
      end
    end
  end
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/services/payment_service_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/services/payment_service.rb spec/services/payment_service_spec.rb
git commit -m "feat: add PaymentService for MercadoPago integration

create_payment! — creates Payment record and returns payment URL
process_webhook! — handles approved/rejected payment notifications
MercadoPago SDK calls stubbed until credentials available."
```

---

## Task 2: Payments Controller

**Files:**
- Create: `app/controllers/api/v1/payments_controller.rb`
- Create: `spec/requests/api/v1/payments_spec.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Add payment route**

In `config/routes.rb`, inside `namespace :v1`, add or update orders:

```ruby
      resources :orders, only: [ :index, :show, :create ], param: :order_number do
        post "pay", on: :member, to: "payments#create"
        resource :shipment, only: [ :show ], on: :member
      end
```

- [ ] **Step 2: Write request specs**

Create `spec/requests/api/v1/payments_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Payments", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "POST /api/v1/orders/:order_number/pay" do
    it "creates a payment and returns payment URL" do
      order = create(:order, customer_profile: profile)

      authenticated_post "/api/v1/orders/#{order.order_number}/pay",
        customer_profile: profile

      expect(response).to have_http_status(:created)
      expect(json_data[:payment_url]).to be_present
    end

    it "returns 401 without authentication" do
      order = create(:order)

      post "/api/v1/orders/#{order.order_number}/pay"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 404 for another user's order" do
      other_order = create(:order)

      authenticated_post "/api/v1/orders/#{other_order.order_number}/pay",
        customer_profile: profile

      expect(response).to have_http_status(:not_found)
    end
  end
end
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/payments_spec.rb`

- [ ] **Step 4: Implement PaymentsController**

Create `app/controllers/api/v1/payments_controller.rb`:

```ruby
module Api
  module V1
    class PaymentsController < BaseController
      before_action :authenticate!

      def create
        order = current_customer_profile.orders
          .find_by!(order_number: params[:order_number])

        payment = PaymentService.create_payment!(order)

        render_created({
          payment_id: payment.id,
          payment_url: payment.payment_url,
          amount: payment.amount,
          currency: payment.currency
        })
      end
    end
  end
end
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/payments_spec.rb`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app/controllers/api/v1/payments_controller.rb spec/requests/api/v1/payments_spec.rb config/routes.rb
git commit -m "feat: add Payments API

POST /api/v1/orders/:order_number/pay — creates payment and
returns MercadoPago payment URL for redirect."
```

---

## Task 3: Webhooks Controller

**Files:**
- Create: `app/controllers/api/v1/webhooks_controller.rb`
- Create: `spec/requests/api/v1/webhooks_spec.rb`

- [ ] **Step 1: Add webhook route**

In `config/routes.rb`, inside `namespace :v1`, add:

```ruby
      post "webhooks/mercadopago", to: "webhooks#mercadopago"
```

- [ ] **Step 2: Write request specs**

Create `spec/requests/api/v1/webhooks_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Webhooks", type: :request do
  describe "POST /api/v1/webhooks/mercadopago" do
    it "processes approved payment" do
      order = create(:order, :pending)
      payment = create(:payment, order: order)
      product = create(:product)
      create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      post "/api/v1/webhooks/mercadopago", params: {
        type: "payment",
        data: {
          id: "MP-WEBHOOK-123"
        },
        action: "payment.updated",
        external_reference: order.order_number,
        status: "approved"
      }

      expect(response).to have_http_status(:ok)
      expect(payment.reload).to be_completed
      expect(order.reload).to be_processing
    end

    it "returns 200 even for unknown events (idempotent)" do
      post "/api/v1/webhooks/mercadopago", params: {
        type: "unknown",
        data: { id: "123" }
      }

      expect(response).to have_http_status(:ok)
    end
  end
end
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/webhooks_spec.rb`

- [ ] **Step 4: Implement WebhooksController**

Create `app/controllers/api/v1/webhooks_controller.rb`:

```ruby
module Api
  module V1
    class WebhooksController < BaseController
      # No JWT authentication for webhooks — they use signature verification
      # TODO: Add MercadoPago signature verification when SDK is integrated

      def mercadopago
        return head :ok unless params[:type] == "payment"

        order = Order.find_by(order_number: params[:external_reference])
        return head :ok unless order

        PaymentService.process_webhook!(
          provider_payment_id: params.dig(:data, :id),
          status: params[:status],
          order: order
        )

        head :ok
      rescue StandardError => e
        Rails.logger.error("Webhook processing error: #{e.message}")
        head :ok # Always return 200 to prevent retries for unrecoverable errors
      end
    end
  end
end
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/webhooks_spec.rb`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app/controllers/api/v1/webhooks_controller.rb spec/requests/api/v1/webhooks_spec.rb config/routes.rb
git commit -m "feat: add MercadoPago webhook endpoint

POST /api/v1/webhooks/mercadopago — processes payment notifications.
No JWT auth (server-to-server). TODO: add signature verification.
Always returns 200 to prevent webhook retries."
```

---

## Task 4: Reservation Timeout Job

**Files:**
- Create: `app/jobs/reservation_timeout_job.rb` (via generator)
- Create: `spec/jobs/reservation_timeout_job_spec.rb`

- [ ] **Step 1: Generate job**

Run: `rails generate job ReservationTimeout`
Expected: Creates `app/jobs/reservation_timeout_job.rb` and spec file.

- [ ] **Step 2: Write job spec**

Replace the generated spec (`spec/jobs/reservation_timeout_job_spec.rb`):

```ruby
require "rails_helper"

RSpec.describe ReservationTimeoutJob, type: :job do
  describe "#perform" do
    it "cancels expired pending orders (older than 30 minutes)" do
      product = create(:product)
      inventory = create(:inventory, product: product, stock: 10, reserved_stock: 2)

      old_order = create(:order, :pending, created_at: 31.minutes.ago)
      create(:order_item, order: old_order, product: product, quantity: 2)

      recent_order = create(:order, :pending, created_at: 5.minutes.ago)

      described_class.perform_now

      expect(old_order.reload).to be_cancelled
      expect(recent_order.reload).to be_pending
      expect(inventory.reload.reserved_stock).to eq(0)
    end

    it "does not cancel paid orders" do
      paid_order = create(:order, :paid, created_at: 31.minutes.ago)

      described_class.perform_now

      expect(paid_order.reload).to be_paid
    end
  end
end
```

- [ ] **Step 3: Run test to verify it fails**

Run: `bundle exec rspec spec/jobs/reservation_timeout_job_spec.rb`

- [ ] **Step 4: Implement the job**

Replace `app/jobs/reservation_timeout_job.rb`:

```ruby
class ReservationTimeoutJob < ApplicationJob
  queue_as :default

  RESERVATION_TTL = 30.minutes

  def perform
    expired_orders = Order.pending.where("created_at < ?", RESERVATION_TTL.ago)

    expired_orders.find_each do |order|
      ActiveRecord::Base.transaction do
        # Release inventory reservations
        order.order_items.includes(product: :inventory).each do |item|
          next unless item.product.inventory

          InventoryService.release!(item.product.inventory, item.quantity)
        end

        # Cancel the order
        order.cancel!
      end

      Rails.logger.info("Cancelled expired order #{order.order_number}")
    rescue StandardError => e
      Rails.logger.error("Failed to cancel order #{order.order_number}: #{e.message}")
    end
  end
end
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bundle exec rspec spec/jobs/reservation_timeout_job_spec.rb`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app/jobs/reservation_timeout_job.rb spec/jobs/reservation_timeout_job_spec.rb
git commit -m "feat: add ReservationTimeoutJob for expired orders

Cancels pending orders older than 30 minutes and releases
their inventory reservations. Can be triggered by cron/scheduler."
```

---

## Task 5: Final Verification

- [ ] **Step 1: Run full test suite**

Run: `bundle exec rspec --format documentation`
Expected: All specs pass.

- [ ] **Step 2: Run RuboCop**

Run: `bundle exec rubocop`

- [ ] **Step 3: Verify all routes**

Run: `rails routes | grep api`
Expected: All payment, webhook, and admin routes present.

- [ ] **Step 4: Verify final route summary matches spec**

Verify the routes cover all endpoints from the architecture spec:
- Public: products (list, detail, search), categories (list, show), reviews (list)
- Authenticated: cart (CRUD, sync), wishlist (list, add, remove), orders (list, detail, create), payments (pay), profile (show, update), addresses (CRUD), reviews (create), shipments (show)
- Admin: products (CRUD), orders (list, status, shipment), inventory (list, low-stock, update), customers (list, detail), dashboard (stats)
- Webhooks: mercadopago
