# Payments API

Initiate payment for orders using the configured payment provider.

**Base Path:** `/api/v1/orders/:order_number`

**Authentication:** JWT required

---

## Initiate Payment

```
POST /api/v1/orders/:order_number/pay
```

Creates a payment intent and returns payment URL for redirect.

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `order_number` | string | Yes | Order number (e.g., `CRA-20260322-0001`) |

### Request Headers

```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

### Example Request

```bash
POST /api/v1/orders/CRA-20260322-0001/pay
Authorization: Bearer eyJhbGci...
```

### Example Response (201 Created)

```json
{
  "data": {
    "payment_id": 42,
    "payment_url": "https://payments.craftitapp.local/pay/SIM-abc123def456?order=CRA-20260322-0001",
    "amount": "1575.00",
    "currency": "MXN"
  }
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `payment_id` | integer | Payment record ID |
| `payment_url` | string | URL to redirect user for payment |
| `amount` | string | Total amount (decimal as string) |
| `currency` | string | Currency code (always `MXN`) |

### Error Responses

**401 Unauthorized** — Missing or invalid JWT

```json
{
  "error": {
    "code": "unauthorized",
    "message": "Authentication required"
  }
}
```

**404 Not Found** — Order not found or belongs to another user

```json
{
  "error": {
    "code": "not_found",
    "message": "Couldn't find Order"
  }
}
```

**422 Unprocessable Entity** — Payment already exists

```json
{
  "error": {
    "code": "payment_already_exists",
    "message": "Payment already exists for this order"
  }
}
```

---

## Payment Flow

### 1. Create Order

```
POST /api/v1/orders
```

Creates order with `pending` status and reserves inventory.

### 2. Initiate Payment

```
POST /api/v1/orders/:order_number/pay
```

**Backend actions:**
1. Delegates to `PaymentService.create_payment!(order)`
2. Payment provider creates payment intent (Strategy pattern)
3. Returns `payment_url` for redirect

**Simulated Provider:**
- Returns fake URL: `https://payments.craftitapp.local/pay/SIM-...`
- Schedules `AutoApprovePaymentJob` (30 seconds delay by default)

**Real Provider (MercadoPago, Stripe):**
- Returns actual payment gateway URL
- User completes payment on external site

### 3. Payment Completion

Two paths:

**A. Webhook Notification (Production)**
- Payment provider sends webhook to `/api/v1/webhooks/payment`
- Rails processes webhook → updates payment status → transitions order

**B. Auto-Approval (Simulated Only)**
- `AutoApprovePaymentJob` runs after delay
- Automatically approves payment for testing

**C. Manual Approval (Dev Only)**
- POST `/api/v1/dev/simulated_payments/:provider_payment_id/approve`
- Immediately approves payment (no wait)

### 4. Order Status Transitions

```
Order:   pending → paid → processing → shipped → delivered
Payment: pending → completed
```

On payment approval:
- `Payment.status` → `completed`
- `Order.status` → `paid` → `processing`
- Inventory: `reserved_stock` confirmed (deducted from `stock`)

---

## Payment Providers (Strategy Pattern)

The API uses a **provider-agnostic architecture** via the Strategy pattern.

### Current Provider: Simulated

**Configuration:**
```bash
PAYMENT_PROVIDER=simulated
SIMULATED_PAYMENT_AUTO_APPROVE_DELAY=30  # seconds
```

**Features:**
- No external API calls
- Fake payment URLs for testing
- Auto-approval job (configurable delay)
- Manual approval endpoints (dev-only)

**Provider ID Pattern:** `SIM-<random_hex>`

### Adding Real Providers

To integrate MercadoPago, Stripe, or any provider:

1. **Create provider adapter** at `app/services/payment_providers/mercadopago_provider.rb`:

```ruby
module PaymentProviders
  class MercadopagoProvider < BaseProvider
    def create_payment_intent!(order)
      # MercadoPago SDK integration
      sdk = MercadoPago::SDK.new(ENV['MERCADOPAGO_ACCESS_TOKEN'])
      preference = sdk.preference.create(...)

      {
        payment_url: preference.init_point,
        provider_payment_id: preference.id
      }
    end

    def verify_webhook_signature(payload, signature)
      # MercadoPago signature verification
    end
  end
end
```

2. **Update environment:**

```bash
PAYMENT_PROVIDER=mercadopago
MERCADOPAGO_ACCESS_TOKEN=...
MERCADOPAGO_WEBHOOK_SECRET=...
```

3. **No code changes needed** in `PaymentService`, controllers, or jobs!

---

## Related Endpoints

- [Orders API](orders.md) — Create and list orders
- [Webhooks](webhooks.md) — Payment webhook processing
- [Dev Endpoints](#dev-manual-approval) — Manual payment approval (dev-only)

---

## Dev-Only: Manual Approval

**⚠️ Only available in development/test environments**

### Approve Payment

```
POST /api/v1/dev/simulated_payments/:provider_payment_id/approve
```

**Example:**
```bash
POST /api/v1/dev/simulated_payments/SIM-abc123def456/approve
```

**Response (200 OK):**
```json
{
  "data": {
    "message": "Payment approved",
    "payment_id": 42
  }
}
```

### Reject Payment

```
POST /api/v1/dev/simulated_payments/:provider_payment_id/reject
```

**Example:**
```bash
POST /api/v1/dev/simulated_payments/SIM-abc123def456/reject
```

**Response (200 OK):**
```json
{
  "data": {
    "message": "Payment rejected",
    "payment_id": 42
  }
}
```

### Production Safeguard

Attempting to use dev endpoints in production returns:

```json
{
  "error": {
    "code": "forbidden",
    "message": "Dev endpoints are only available in development/test"
  }
}
```

---

## Testing

### RSpec Request Specs

**Location:** `spec/requests/api/v1/payments_spec.rb`

**Key scenarios:**
- Initiate payment for user's order
- 401 without authentication
- 404 for other user's order
- 422 for duplicate payment
- Dev manual approval (test env only)

### Manual Testing Flow

1. Create order: `POST /api/v1/orders`
2. Get `order_number` from response
3. Initiate payment: `POST /api/v1/orders/:order_number/pay`
4. Copy `provider_payment_id` from `payment_url`
5. **Option A:** Wait 30 seconds (auto-approve)
6. **Option B:** Manual approve: `POST /api/v1/dev/simulated_payments/:id/approve`
7. Verify order status: `GET /api/v1/orders/:order_number`

---

## Implementation Details

**Controller:** `app/controllers/api/v1/payments_controller.rb`

**Service:** `app/services/payment_service.rb`

**Providers:**
- `app/services/payment_providers/base_provider.rb` (interface)
- `app/services/payment_providers/simulated_provider.rb` (default)

**Jobs:**
- `app/jobs/auto_approve_payment_job.rb` (simulated auto-approval)

**Models:**
- `Payment` (AASM states: `pending`, `completed`, `failed`, `refunded`)
- `Order` (AASM state machine)
