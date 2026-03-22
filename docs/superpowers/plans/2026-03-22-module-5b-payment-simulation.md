# Module 5B: Payment Simulation Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build payment flow infrastructure using the Strategy pattern with a simulation provider that supports manual and auto-approval. Architecture is ready for drop-in replacement with real payment providers (MercadoPago, Stripe, etc.) without changing consumer code.

**Architecture:** PaymentService delegates to provider-specific adapters via a common PaymentProvider interface. SimulatedPaymentProvider handles both manual approval (dev endpoint) and auto-approval (background job). Webhooks controller processes payment notifications. ReservationTimeoutJob cancels unpaid orders after 30 minutes.

**Tech Stack:** Rails 8.1, ActiveJob, AASM, RSpec, FactoryBot

**Spec reference:** `craftitapp/docs/superpowers/specs/2026-03-21-backend-architecture-design.md` — Core Flows > Payment webhooks

**Depends on:** Modules 1-5A must be completed first.

**Prerequisites from Module 2B (Data Model — Commerce):**
- Payment model with AASM states: `pending`, `completed`, `failed`, `refunded`
- Payment AASM events: `complete!`, `fail_payment!`, `refund!`
- Order model with AASM states: `pending`, `paid`, `processing`, `shipped`, `delivered`, `cancelled`
- Order AASM events: `pay!`, `process!`, `ship!`, `deliver!`, `cancel!`

**Prerequisites from Module 4B (Authenticated API — Orders & Services):**
- InventoryService with methods: `reserve!(inventory, quantity)`, `confirm!(inventory, quantity)`, `release!(inventory, quantity)`

**Strategy Pattern Benefits:**
- Drop-in provider replacement (change one ENV var)
- Each provider is isolated in its own adapter
- Easy to add new providers (MercadoPago, Stripe, PayPal)
- Testable without external dependencies

---

## File Structure

```
craftit-api/
├── app/
│   ├── controllers/api/v1/
│   │   ├── payments_controller.rb             # CREATE
│   │   ├── webhooks_controller.rb             # CREATE
│   │   └── dev/
│   │       └── simulated_payments_controller.rb  # CREATE (dev-only)
│   ├── services/
│   │   ├── payment_service.rb                 # CREATE
│   │   └── payment_providers/
│   │       ├── base_provider.rb               # CREATE (interface)
│   │       └── simulated_provider.rb          # CREATE
│   └── jobs/
│       ├── reservation_timeout_job.rb         # CREATE
│       └── auto_approve_payment_job.rb        # CREATE
├── config/
│   └── routes.rb                              # MODIFY
└── spec/
    ├── requests/api/v1/
    │   ├── payments_spec.rb                   # CREATE
    │   ├── webhooks_spec.rb                   # CREATE
    │   └── dev/
    │       └── simulated_payments_spec.rb     # CREATE
    ├── services/
    │   ├── payment_service_spec.rb            # CREATE
    │   └── payment_providers/
    │       └── simulated_provider_spec.rb     # CREATE
    └── jobs/
        ├── reservation_timeout_job_spec.rb    # CREATE
        └── auto_approve_payment_job_spec.rb   # CREATE
```

---

## Task 0: Prerequisites Check

**Files:**
- Read: `app/models/payment.rb` (from Module 2B)
- Read: `app/models/order.rb` (from Module 2B)
- Read: `app/services/inventory_service.rb` (from Module 4B)

- [ ] **Step 1: Verify Payment model exists with required AASM states**

Run: `bundle exec rails runner "puts Payment.aasm.states.map(&:name).inspect"`

Expected output: `[:pending, :completed, :failed, :refunded]`

If this fails, Module 2B was not completed. Stop and complete Module 2B first.

- [ ] **Step 2: Verify Payment AASM events**

Run: `bundle exec rails runner "p = Payment.create!(order: Order.new, provider: 'test', amount: 100, currency: 'MXN'); p.complete!; puts p.status"`

Expected output: `completed`

- [ ] **Step 3: Verify Order model has required AASM events**

Run: `bundle exec rails runner "o = Order.new; puts o.respond_to?(:pay!) && o.respond_to?(:process!) && o.respond_to?(:cancel!)"`

Expected output: `true`

- [ ] **Step 4: Verify InventoryService exists with required methods**

Run: `bundle exec rails runner "puts InventoryService.respond_to?(:reserve!) && InventoryService.respond_to?(:confirm!) && InventoryService.respond_to?(:release!)"`

Expected output: `true`

If any of these checks fail, the required modules are not complete. Review and complete them before proceeding.

---

## Task 1: Base Payment Provider Interface

**Files:**
- Create: `app/services/payment_providers/base_provider.rb`
- Create: `spec/services/payment_providers/base_provider_spec.rb`

- [ ] **Step 1: Create directory**

Run: `mkdir -p app/services/payment_providers spec/services/payment_providers`

- [ ] **Step 2: Write base provider interface**

Create `app/services/payment_providers/base_provider.rb`:

```ruby
module PaymentProviders
  # Abstract base class defining the interface all payment providers must implement.
  # Consumers use PaymentService, which delegates to the active provider.
  #
  # To add a new provider:
  # 1. Create a class inheriting from BaseProvider
  # 2. Implement create_payment_intent! and verify_webhook_signature
  # 3. Set PAYMENT_PROVIDER env var to the class name
  #
  # Example:
  #   class MercadopagoProvider < BaseProvider
  #     def create_payment_intent!(order)
  #       # ... MercadoPago SDK logic
  #     end
  #   end
  class BaseProvider
    class NotImplementedError < StandardError; end
    class PaymentError < StandardError; end

    # Creates a payment intent with the provider and returns payment URL + metadata
    #
    # @param order [Order] The order to create payment for
    # @return [Hash] { payment_url: String, provider_payment_id: String }
    # @raise [PaymentError] if payment creation fails
    def create_payment_intent!(order)
      raise NotImplementedError, "#{self.class} must implement create_payment_intent!"
    end

    # Verifies webhook signature from the payment provider
    #
    # @param payload [String] Raw request body
    # @param signature [String] Signature header from the provider
    # @return [Boolean] true if signature is valid
    def verify_webhook_signature(payload, signature)
      raise NotImplementedError, "#{self.class} must implement verify_webhook_signature"
    end
  end
end
```

- [ ] **Step 3: Write spec**

Create `spec/services/payment_providers/base_provider_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe PaymentProviders::BaseProvider do
  subject(:provider) { described_class.new }

  describe "#create_payment_intent!" do
    it "raises NotImplementedError" do
      order = build(:order)
      expect {
        provider.create_payment_intent!(order)
      }.to raise_error(PaymentProviders::BaseProvider::NotImplementedError)
    end
  end

  describe "#verify_webhook_signature" do
    it "raises NotImplementedError" do
      expect {
        provider.verify_webhook_signature("payload", "signature")
      }.to raise_error(PaymentProviders::BaseProvider::NotImplementedError)
    end
  end
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/services/payment_providers/base_provider_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/services/payment_providers/base_provider.rb spec/services/payment_providers/base_provider_spec.rb
git commit -m "feat: add BaseProvider interface for payment providers

Strategy pattern interface for pluggable payment providers.
Defines create_payment_intent! and verify_webhook_signature methods.
Ready for MercadoPago, Stripe, or any provider implementation."
```

---

## Task 2: Simulated Payment Provider

**Files:**
- Create: `app/services/payment_providers/simulated_provider.rb`
- Create: `spec/services/payment_providers/simulated_provider_spec.rb`

- [ ] **Step 1: Write provider spec**

Create `spec/services/payment_providers/simulated_provider_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe PaymentProviders::SimulatedProvider do
  subject(:provider) { described_class.new }

  describe "#create_payment_intent!" do
    it "returns a simulated payment URL" do
      order = create(:order, total: 1500.00)

      result = provider.create_payment_intent!(order)

      expect(result[:payment_url]).to match(%r{^https://payments\.craftitapp\.local/pay/})
      expect(result[:provider_payment_id]).to match(/^SIM-/)
    end

    it "includes order_number in the URL" do
      order = create(:order, total: 1500.00)

      result = provider.create_payment_intent!(order)

      expect(result[:payment_url]).to include(order.order_number)
    end
  end

  describe "#verify_webhook_signature" do
    it "returns true for any payload in development/test" do
      expect(provider.verify_webhook_signature("payload", "signature")).to be true
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/services/payment_providers/simulated_provider_spec.rb`

- [ ] **Step 3: Implement SimulatedProvider**

Create `app/services/payment_providers/simulated_provider.rb`:

```ruby
module PaymentProviders
  # Simulated payment provider for development and testing.
  #
  # Features:
  # - Returns a fake payment URL (no external redirect)
  # - Generates provider_payment_id with SIM- prefix
  # - Supports manual approval via dev endpoint
  # - Supports auto-approval via background job (configurable delay)
  # - No signature verification (always returns true)
  #
  # Configuration:
  # - SIMULATED_PAYMENT_AUTO_APPROVE_DELAY (seconds, default: 30)
  #
  # Usage:
  #   Set PAYMENT_PROVIDER=simulated in .env
  class SimulatedProvider < BaseProvider
    PAYMENT_URL_BASE = "https://payments.craftitapp.local/pay".freeze

    def create_payment_intent!(order)
      provider_payment_id = generate_payment_id

      {
        payment_url: "#{PAYMENT_URL_BASE}/#{provider_payment_id}?order=#{order.order_number}",
        provider_payment_id: provider_payment_id
      }
    end

    def verify_webhook_signature(payload, signature)
      # Simulated provider doesn't verify signatures
      true
    end

    private

    def generate_payment_id
      "SIM-#{SecureRandom.hex(12)}"
    end
  end
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/services/payment_providers/simulated_provider_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/services/payment_providers/simulated_provider.rb spec/services/payment_providers/simulated_provider_spec.rb
git commit -m "feat: add SimulatedProvider for payment testing

Returns fake payment URLs with SIM- prefixed IDs.
No external redirect or signature verification.
Ready for manual and auto-approval flows."
```

---

## Task 3: PaymentService with Provider Delegation

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
      expect(payment.provider).to eq("simulated")
      expect(payment.amount).to eq(1500.00)
      expect(payment.currency).to eq("MXN")
      expect(payment.provider_payment_id).to be_present
    end

    it "returns payment_url from provider" do
      order = create(:order, total: 1500.00)

      result = PaymentService.create_payment!(order)

      expect(result[:payment_url]).to be_present
      expect(result[:payment_url]).to match(/payments\.craftitapp\.local/)
    end

    it "schedules auto-approval job" do
      order = create(:order, total: 1500.00)

      expect {
        PaymentService.create_payment!(order)
      }.to have_enqueued_job(AutoApprovePaymentJob)
    end
  end

  describe ".process_webhook!" do
    it "completes payment and transitions order to processing" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-123")
      product = create(:product)
      create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      PaymentService.process_webhook!(
        provider_payment_id: "SIM-123",
        status: "approved"
      )

      expect(payment.reload).to be_completed
      expect(order.reload).to be_processing
    end

    it "confirms inventory (deducts reserved stock and stock)" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-123")
      product = create(:product)
      inventory = create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      PaymentService.process_webhook!(
        provider_payment_id: "SIM-123",
        status: "approved"
      )

      expect(inventory.reload.stock).to eq(8)
      expect(inventory.reload.reserved_stock).to eq(0)
    end

    it "marks payment as failed for rejected status" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-123")

      PaymentService.process_webhook!(
        provider_payment_id: "SIM-123",
        status: "rejected"
      )

      expect(payment.reload).to be_failed
      expect(order.reload).to be_pending
    end

    it "returns nil for unknown provider_payment_id" do
      result = PaymentService.process_webhook!(
        provider_payment_id: "UNKNOWN",
        status: "approved"
      )

      expect(result).to be_nil
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
  # Auto-approval delay for simulated payments (in seconds)
  AUTO_APPROVE_DELAY = ENV.fetch("SIMULATED_PAYMENT_AUTO_APPROVE_DELAY", "30").to_i.seconds

  class << self
    # Creates a payment and initiates payment intent with the active provider
    #
    # @param order [Order]
    # @return [Hash] { payment_url: String, payment: Payment }
    def create_payment!(order)
      provider_result = payment_provider.create_payment_intent!(order)

      payment = order.create_payment!(
        provider: provider_name,
        provider_payment_id: provider_result[:provider_payment_id],
        amount: order.total,
        currency: "MXN"
      )

      # Schedule auto-approval for simulated payments
      if provider_name == "simulated"
        AutoApprovePaymentJob.set(wait: AUTO_APPROVE_DELAY).perform_later(payment.id)
      end

      {
        payment_url: provider_result[:payment_url],
        payment: payment
      }
    end

    # Processes webhook notification from payment provider
    #
    # @param provider_payment_id [String]
    # @param status [String] "approved", "rejected", "cancelled"
    def process_webhook!(provider_payment_id:, status:)
      payment = Payment.find_by(provider_payment_id: provider_payment_id)
      return unless payment

      order = payment.order

      ActiveRecord::Base.transaction do
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

      payment
    end

    private

    def payment_provider
      @payment_provider ||= begin
        provider_class_name = "PaymentProviders::#{provider_name.camelize}Provider"
        provider_class_name.constantize.new
      rescue NameError
        raise "Payment provider '#{provider_name}' not found. Check PAYMENT_PROVIDER env var."
      end
    end

    def provider_name
      ENV.fetch("PAYMENT_PROVIDER", "simulated")
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
git commit -m "feat: add PaymentService with provider delegation

Delegates to pluggable payment providers via Strategy pattern.
create_payment! — creates Payment and returns provider URL.
process_webhook! — handles approved/rejected notifications.
Auto-schedules approval job for simulated provider."
```

---

## Task 4: Auto-Approve Payment Job

**Files:**
- Create: `app/jobs/auto_approve_payment_job.rb`
- Create: `spec/jobs/auto_approve_payment_job_spec.rb`

- [ ] **Step 1: Generate job**

Run: `rails generate job AutoApprovePayment`

- [ ] **Step 2: Write job spec**

Replace `spec/jobs/auto_approve_payment_job_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe AutoApprovePaymentJob, type: :job do
  describe "#perform" do
    it "auto-approves pending payment after delay" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-123")
      product = create(:product)
      create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      described_class.perform_now(payment.id)

      expect(payment.reload).to be_completed
      expect(order.reload).to be_processing
    end

    it "does nothing if payment already completed" do
      order = create(:order, :paid)
      payment = create(:payment, :completed, order: order)

      expect {
        described_class.perform_now(payment.id)
      }.not_to change { payment.reload.status }
    end

    it "does nothing if payment does not exist" do
      expect {
        described_class.perform_now(999999)
      }.not_to raise_error
    end
  end
end
```

- [ ] **Step 3: Run test to verify it fails**

Run: `bundle exec rspec spec/jobs/auto_approve_payment_job_spec.rb`

- [ ] **Step 4: Implement the job**

Replace `app/jobs/auto_approve_payment_job.rb`:

```ruby
# Auto-approves simulated payments after configured delay.
# Only processes payments still in pending state.
class AutoApprovePaymentJob < ApplicationJob
  queue_as :default

  def perform(payment_id)
    payment = Payment.find_by(id: payment_id)
    return unless payment
    return unless payment.pending?

    Rails.logger.info("Auto-approving simulated payment #{payment.provider_payment_id}")

    PaymentService.process_webhook!(
      provider_payment_id: payment.provider_payment_id,
      status: "approved"
    )
  end
end
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bundle exec rspec spec/jobs/auto_approve_payment_job_spec.rb`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app/jobs/auto_approve_payment_job.rb spec/jobs/auto_approve_payment_job_spec.rb
git commit -m "feat: add AutoApprovePaymentJob for simulated payments

Auto-approves pending simulated payments after delay.
Scheduled by PaymentService when creating simulated payments.
Idempotent — skips if payment already processed."
```

---

## Task 5: Payments Controller

**Files:**
- Create: `app/controllers/api/v1/payments_controller.rb`
- Create: `spec/requests/api/v1/payments_spec.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Add payment route**

In `config/routes.rb`, inside `namespace :v1`, update the orders route:

```ruby
      resources :orders, only: [ :index, :show, :create ], param: :order_number do
        post "pay", on: :member, to: "payments#create"
        get "shipment", on: :member, to: "shipments#show"
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
      expect(json_data[:amount]).to eq(order.total.to_s)
      expect(json_data[:currency]).to eq("MXN")
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

    it "returns 422 if payment already exists" do
      order = create(:order, customer_profile: profile)
      create(:payment, order: order)

      authenticated_post "/api/v1/orders/#{order.order_number}/pay",
        customer_profile: profile

      expect(response).to have_http_status(:unprocessable_entity)
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

        if order.payment.present?
          return render_error(
            code: "payment_already_exists",
            message: "Payment already exists for this order",
            status: :unprocessable_entity
          )
        end

        result = PaymentService.create_payment!(order)

        render_created({
          payment_id: result[:payment].id,
          payment_url: result[:payment_url],
          amount: result[:payment].amount,
          currency: result[:payment].currency
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
git commit -m "feat: add Payments API endpoint

POST /api/v1/orders/:order_number/pay — creates payment and
returns payment URL. Prevents duplicate payments for same order."
```

---

## Task 6: Webhooks Controller

**Files:**
- Create: `app/controllers/api/v1/webhooks_controller.rb`
- Create: `spec/requests/api/v1/webhooks_spec.rb`

- [ ] **Step 1: Add webhook route**

In `config/routes.rb`, inside `namespace :v1`, add:

```ruby
      # Webhook endpoint - provider-agnostic route that delegates to WebhooksController
      # Route uses generic naming to support multiple providers (simulated, mercadopago, stripe)
      # Real provider webhooks can POST to same endpoint with provider identification in payload
      post "webhooks/payment", to: "webhooks#payment"
```

**Note:** The spec mentions `/webhooks/mercadopago` but we use `/webhooks/payment` here for provider-agnostic design. When migrating to MercadoPago, you can either:
- Keep this route and have MercadoPago POST to `/webhooks/payment`
- Add an alias route: `post "webhooks/mercadopago", to: "webhooks#payment"`

- [ ] **Step 2: Write request specs**

Create `spec/requests/api/v1/webhooks_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Webhooks", type: :request do
  describe "POST /api/v1/webhooks/payment" do
    it "processes approved payment webhook" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-123")
      product = create(:product)
      create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      post "/api/v1/webhooks/payment", params: {
        provider_payment_id: "SIM-123",
        status: "approved"
      }

      expect(response).to have_http_status(:ok)
      expect(payment.reload).to be_completed
      expect(order.reload).to be_processing
    end

    it "processes rejected payment webhook" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-456")

      post "/api/v1/webhooks/payment", params: {
        provider_payment_id: "SIM-456",
        status: "rejected"
      }

      expect(response).to have_http_status(:ok)
      expect(payment.reload).to be_failed
    end

    it "returns 200 for unknown payment (idempotent)" do
      post "/api/v1/webhooks/payment", params: {
        provider_payment_id: "UNKNOWN",
        status: "approved"
      }

      expect(response).to have_http_status(:ok)
    end

    it "returns 200 even on processing errors" do
      allow(PaymentService).to receive(:process_webhook!).and_raise(StandardError, "boom")

      post "/api/v1/webhooks/payment", params: {
        provider_payment_id: "SIM-123",
        status: "approved"
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
      skip_before_action :verify_authenticity_token, only: :payment

      def payment
        # TODO: Verify webhook signature when using real provider
        # provider = PaymentService.send(:payment_provider)
        # unless provider.verify_webhook_signature(request.raw_post, request.headers['X-Signature'])
        #   return head :unauthorized
        # end

        PaymentService.process_webhook!(
          provider_payment_id: params[:provider_payment_id],
          status: params[:status]
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
git commit -m "feat: add payment webhook endpoint

POST /api/v1/webhooks/payment — processes payment notifications.
No JWT auth (server-to-server). Always returns 200 to prevent
webhook retries. TODO: add signature verification for real providers."
```

---

## Task 7: Dev-Only Manual Payment Approval Endpoint

**Files:**
- Create: `app/controllers/api/v1/dev/simulated_payments_controller.rb`
- Create: `spec/requests/api/v1/dev/simulated_payments_spec.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Add dev namespace route**

In `config/routes.rb`, inside `namespace :v1`, add:

```ruby
      namespace :dev do
        post "simulated_payments/:provider_payment_id/approve", to: "simulated_payments#approve"
        post "simulated_payments/:provider_payment_id/reject", to: "simulated_payments#reject"
      end
```

- [ ] **Step 2: Write request specs**

Create `spec/requests/api/v1/dev/simulated_payments_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Api::V1::Dev::SimulatedPayments", type: :request do
  describe "POST /api/v1/dev/simulated_payments/:provider_payment_id/approve" do
    it "manually approves a pending payment" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-TEST-123")
      product = create(:product)
      create(:inventory, product: product, stock: 10, reserved_stock: 2)
      create(:order_item, order: order, product: product, quantity: 2)

      post "/api/v1/dev/simulated_payments/SIM-TEST-123/approve"

      expect(response).to have_http_status(:ok)
      expect(payment.reload).to be_completed
      expect(order.reload).to be_processing
      expect(json_data[:message]).to eq("Payment approved")
    end

    it "returns 404 for unknown payment" do
      post "/api/v1/dev/simulated_payments/UNKNOWN/approve"

      expect(response).to have_http_status(:not_found)
    end

    it "is disabled in production" do
      allow(Rails.env).to receive(:production?).and_return(true)

      post "/api/v1/dev/simulated_payments/SIM-123/approve"

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/dev/simulated_payments/:provider_payment_id/reject" do
    it "manually rejects a pending payment" do
      order = create(:order, :pending)
      payment = create(:payment, order: order, provider_payment_id: "SIM-TEST-456")

      post "/api/v1/dev/simulated_payments/SIM-TEST-456/reject"

      expect(response).to have_http_status(:ok)
      expect(payment.reload).to be_failed
      expect(json_data[:message]).to eq("Payment rejected")
    end

    it "is disabled in production" do
      allow(Rails.env).to receive(:production?).and_return(true)

      post "/api/v1/dev/simulated_payments/SIM-123/reject"

      expect(response).to have_http_status(:forbidden)
    end
  end
end
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `bundle exec rspec spec/requests/api/v1/dev/simulated_payments_spec.rb`

- [ ] **Step 4: Implement Dev::SimulatedPaymentsController**

Create `app/controllers/api/v1/dev/simulated_payments_controller.rb`:

```ruby
module Api
  module V1
    module Dev
      # Development-only endpoint for manually approving/rejecting simulated payments.
      # Disabled in production.
      #
      # Usage (from Postman or curl):
      #   POST /api/v1/dev/simulated_payments/SIM-abc123/approve
      #   POST /api/v1/dev/simulated_payments/SIM-abc123/reject
      class SimulatedPaymentsController < BaseController
        before_action :ensure_development_mode

        def approve
          payment = Payment.find_by!(provider_payment_id: params[:provider_payment_id])

          PaymentService.process_webhook!(
            provider_payment_id: payment.provider_payment_id,
            status: "approved"
          )

          render_success(message: "Payment approved", payment_id: payment.id)
        end

        def reject
          payment = Payment.find_by!(provider_payment_id: params[:provider_payment_id])

          PaymentService.process_webhook!(
            provider_payment_id: payment.provider_payment_id,
            status: "rejected"
          )

          render_success(message: "Payment rejected", payment_id: payment.id)
        end

        private

        def ensure_development_mode
          return if Rails.env.development? || Rails.env.test?

          render_error(
            code: "forbidden",
            message: "Dev endpoints are only available in development/test",
            status: :forbidden
          )
        end
      end
    end
  end
end
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bundle exec rspec spec/requests/api/v1/dev/simulated_payments_spec.rb`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add app/controllers/api/v1/dev/simulated_payments_controller.rb spec/requests/api/v1/dev/simulated_payments_spec.rb config/routes.rb
git commit -m "feat: add dev-only manual payment approval endpoint

POST /api/v1/dev/simulated_payments/:id/approve — manual approval
POST /api/v1/dev/simulated_payments/:id/reject — manual rejection
Disabled in production. Useful for testing payment flows in development."
```

---

## Task 8: Reservation Timeout Job

**Files:**
- Create: `app/jobs/reservation_timeout_job.rb`
- Create: `spec/jobs/reservation_timeout_job_spec.rb`

- [ ] **Step 1: Generate job**

Run: `rails generate job ReservationTimeout`

- [ ] **Step 2: Write job spec**

Replace `spec/jobs/reservation_timeout_job_spec.rb`:

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

    it "releases inventory for each cancelled order" do
      product1 = create(:product)
      product2 = create(:product)
      inventory1 = create(:inventory, product: product1, stock: 10, reserved_stock: 3)
      inventory2 = create(:inventory, product: product2, stock: 5, reserved_stock: 1)

      order = create(:order, :pending, created_at: 31.minutes.ago)
      create(:order_item, order: order, product: product1, quantity: 3)
      create(:order_item, order: order, product: product2, quantity: 1)

      described_class.perform_now

      expect(inventory1.reload.reserved_stock).to eq(0)
      expect(inventory2.reload.reserved_stock).to eq(0)
    end
  end
end
```

- [ ] **Step 3: Run test to verify it fails**

Run: `bundle exec rspec spec/jobs/reservation_timeout_job_spec.rb`

- [ ] **Step 4: Implement the job**

Replace `app/jobs/reservation_timeout_job.rb`:

```ruby
# Cancels pending orders older than 30 minutes and releases their inventory reservations.
# Designed to run periodically via cron/scheduler (e.g., every 10 minutes).
#
# Schedule with whenever gem or similar:
#   every 10.minutes do
#     runner "ReservationTimeoutJob.perform_later"
#   end
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
their inventory reservations. Run periodically via cron/scheduler."
```

---

## Task 9: Final Verification & Documentation

- [ ] **Step 1: Run full test suite**

Run: `bundle exec rspec --format documentation`
Expected: All specs pass.

- [ ] **Step 2: Run RuboCop**

Run: `bundle exec rubocop`
Fix any offenses if needed.

- [ ] **Step 3: Verify routes**

Run: `rails routes | grep -E "(payment|webhook)"`

Expected routes:
```
POST   /api/v1/orders/:order_number/pay                api/v1/payments#create
POST   /api/v1/webhooks/payment                        api/v1/webhooks#payment
POST   /api/v1/dev/simulated_payments/:provider_payment_id/approve   api/v1/dev/simulated_payments#approve
POST   /api/v1/dev/simulated_payments/:provider_payment_id/reject    api/v1/dev/simulated_payments#reject
```

- [ ] **Step 4: Create migration guide comment**

Add comment to `app/services/payment_service.rb` header:

```ruby
# PaymentService - Provider-agnostic payment processing
#
# Architecture: Strategy pattern with pluggable payment providers
#
# Current provider: SimulatedProvider (default)
# Supported providers: Simulated (add MercadoPago, Stripe, etc. as needed)
#
# To add a new provider:
# 1. Create app/services/payment_providers/my_provider.rb inheriting from BaseProvider
# 2. Implement create_payment_intent! and verify_webhook_signature
# 3. Set ENV PAYMENT_PROVIDER=my_provider
#
# Example MercadoPago integration:
#   class MercadopagoProvider < PaymentProviders::BaseProvider
#     def create_payment_intent!(order)
#       sdk = MercadoPago::SDK.new(ENV['MERCADOPAGO_ACCESS_TOKEN'])
#       preference = sdk.preference.create(...)
#       { payment_url: preference.init_point, provider_payment_id: preference.id }
#     end
#
#     def verify_webhook_signature(payload, signature)
#       # MercadoPago signature verification logic
#     end
#   end
#
# Simulated provider features:
# - Auto-approval after 30 seconds (configurable via SIMULATED_PAYMENT_AUTO_APPROVE_DELAY)
# - Manual approval via POST /api/v1/dev/simulated_payments/:id/approve (dev-only)
# - Manual rejection via POST /api/v1/dev/simulated_payments/:id/reject (dev-only)
```

- [ ] **Step 5: Update .env.example**

Add to `.env.example`:

```bash
# Payment Provider Configuration
PAYMENT_PROVIDER=simulated  # Options: simulated, mercadopago, stripe
SIMULATED_PAYMENT_AUTO_APPROVE_DELAY=30  # Seconds until auto-approval (simulated only)

# MercadoPago (when ready to integrate)
# MERCADOPAGO_ACCESS_TOKEN=your_access_token
# MERCADOPAGO_WEBHOOK_SECRET=your_webhook_secret
```

- [ ] **Step 6: Test the full payment flow manually**

Test sequence:
1. Create order: `POST /api/v1/orders`
2. Initiate payment: `POST /api/v1/orders/:order_number/pay`
3. Option A (auto): Wait 30 seconds, verify order status changed to processing
4. Option B (manual): `POST /api/v1/dev/simulated_payments/:provider_payment_id/approve`
5. Verify inventory was confirmed (stock decremented, reserved_stock released)

- [ ] **Step 7: Final commit**

```bash
git add app/services/payment_service.rb .env.example
git commit -m "docs: add payment provider integration guide

Strategy pattern documentation with migration examples.
ENV configuration for provider selection and auto-approval delay.
Manual testing checklist included."
```

---

## Environment Variables

Add to `.env`:

```bash
PAYMENT_PROVIDER=simulated
SIMULATED_PAYMENT_AUTO_APPROVE_DELAY=30
```

---

## Testing the Payment Flow

### Automated testing
```bash
bundle exec rspec spec/services/payment_service_spec.rb
bundle exec rspec spec/jobs/auto_approve_payment_job_spec.rb
bundle exec rspec spec/requests/api/v1/payments_spec.rb
```

### Manual testing with Postman

1. **Create an order** (requires JWT):
```
POST /api/v1/orders
Authorization: Bearer <jwt_token>
{
  "address_id": 1,
  "order_items": [
    { "product_id": 1, "quantity": 2 }
  ]
}
```

2. **Initiate payment**:
```
POST /api/v1/orders/CRA-20260322-0001/pay
Authorization: Bearer <jwt_token>
```

Response:
```json
{
  "data": {
    "payment_id": 1,
    "payment_url": "https://payments.craftitapp.local/pay/SIM-abc123?order=CRA-20260322-0001",
    "amount": "1500.00",
    "currency": "MXN"
  }
}
```

3. **Option A: Wait for auto-approval** (30 seconds by default)

4. **Option B: Manual approval** (dev-only):
```
POST /api/v1/dev/simulated_payments/SIM-abc123/approve
```

5. **Verify order status**:
```
GET /api/v1/orders/CRA-20260322-0001
Authorization: Bearer <jwt_token>
```

Should show `status: "processing"`

---

## Migration Path to Real Provider

When ready to integrate MercadoPago or Stripe:

1. Create `app/services/payment_providers/mercadopago_provider.rb`:

```ruby
module PaymentProviders
  class MercadopagoProvider < BaseProvider
    def create_payment_intent!(order)
      sdk = MercadoPago::SDK.new(ENV['MERCADOPAGO_ACCESS_TOKEN'])

      preference = sdk.preference.create({
        items: order.order_items.map { |item|
          {
            title: item.product_name,
            quantity: item.quantity,
            unit_price: item.price
          }
        },
        external_reference: order.order_number,
        notification_url: "#{ENV['RAILS_API_URL']}/api/v1/webhooks/payment"
      })

      {
        payment_url: preference.init_point,
        provider_payment_id: preference.id
      }
    end

    def verify_webhook_signature(payload, signature)
      # MercadoPago signature verification
      expected = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        ENV['MERCADOPAGO_WEBHOOK_SECRET'],
        payload
      )
      ActiveSupport::SecurityUtils.secure_compare(expected, signature)
    end
  end
end
```

2. Update `.env`:
```bash
PAYMENT_PROVIDER=mercadopago
MERCADOPAGO_ACCESS_TOKEN=your_token
MERCADOPAGO_WEBHOOK_SECRET=your_secret
```

3. No changes needed to PaymentService, controllers, or jobs!

---

## Summary

This plan implements:

✅ **Strategy Pattern** — pluggable payment providers
✅ **Simulated Provider** — no external dependencies
✅ **Auto-approval** — configurable delay via ActiveJob
✅ **Manual approval** — dev-only endpoint for testing
✅ **Webhooks** — generic endpoint ready for real providers
✅ **Reservation timeout** — cancels unpaid orders after 30 min
✅ **Migration ready** — add new provider without changing consumer code

All code follows TDD workflow and Rails conventions from completed modules.
