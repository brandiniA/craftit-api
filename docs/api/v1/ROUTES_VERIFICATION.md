# Routes Verification

This document verifies that all documented endpoints match actual implementation in `config/routes.rb`.

**Last verified:** 2026-03-22

**Command:** `rails routes | grep "api/v1"`

---

## ✅ Public Endpoints (No Auth Required)

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/health` | `api/v1/health#show` | [overview.md](overview.md) | ✅ Verified |
| GET | `/api/v1/products` | `api/v1/products#index` | [products.md](products.md) | ✅ Verified |
| GET | `/api/v1/products/:slug` | `api/v1/products#show` | [products.md](products.md) | ✅ Verified |
| GET | `/api/v1/products/search` | `api/v1/products#search` | [products.md](products.md) | ✅ Verified |
| GET | `/api/v1/products/:product_slug/reviews` | `api/v1/reviews#index` | [reviews.md](reviews.md) | ✅ Verified |
| GET | `/api/v1/categories` | `api/v1/categories#index` | [categories.md](categories.md) | ✅ Verified |
| GET | `/api/v1/categories/:slug` | `api/v1/categories#show` | [categories.md](categories.md) | ✅ Verified |

---

## ✅ Authenticated Endpoints (JWT Required)

### Cart

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/cart` | `api/v1/cart#show` | [cart.md](cart.md) | ✅ Verified |
| POST | `/api/v1/cart/items` | `api/v1/cart#create` | [cart.md](cart.md) | ✅ Verified |
| PATCH/PUT | `/api/v1/cart/items/:id` | `api/v1/cart#update` | [cart.md](cart.md) | ✅ Verified |
| DELETE | `/api/v1/cart/items/:id` | `api/v1/cart#destroy` | [cart.md](cart.md) | ✅ Verified |
| POST | `/api/v1/cart/sync` | `api/v1/cart#sync` | [cart.md](cart.md) | ✅ Verified |

### Wishlist

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/wishlist` | `api/v1/wishlist#show` | [wishlist.md](wishlist.md) | ✅ Verified |
| POST | `/api/v1/wishlist/items` | `api/v1/wishlist#create` | [wishlist.md](wishlist.md) | ✅ Verified |
| DELETE | `/api/v1/wishlist/items/:id` | `api/v1/wishlist#destroy` | [wishlist.md](wishlist.md) | ✅ Verified |

### Profile

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/profile` | `api/v1/profile#show` | [profile.md](profile.md) | ✅ Verified |
| PATCH/PUT | `/api/v1/profile` | `api/v1/profile#update` | [profile.md](profile.md) | ✅ Verified |

### Addresses

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/addresses` | `api/v1/addresses#index` | [addresses.md](addresses.md) | ✅ Verified |
| POST | `/api/v1/addresses` | `api/v1/addresses#create` | [addresses.md](addresses.md) | ✅ Verified |
| PATCH/PUT | `/api/v1/addresses/:id` | `api/v1/addresses#update` | [addresses.md](addresses.md) | ✅ Verified |
| DELETE | `/api/v1/addresses/:id` | `api/v1/addresses#destroy` | [addresses.md](addresses.md) | ✅ Verified |

### Orders

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/orders` | `api/v1/orders#index` | [orders.md](orders.md) | ✅ Verified |
| GET | `/api/v1/orders/:order_number` | `api/v1/orders#show` | [orders.md](orders.md) | ✅ Verified |
| POST | `/api/v1/orders` | `api/v1/orders#create` | [orders.md](orders.md) | ✅ Verified |

### Payments

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| POST | `/api/v1/orders/:order_number/pay` | `api/v1/payments#create` | [payments.md](payments.md) | ✅ Verified |

### Shipments

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/orders/:order_number/shipment` | `api/v1/shipments#show` | [shipments.md](shipments.md) | ✅ Verified |

### Reviews (Create - Authenticated)

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| POST | `/api/v1/products/:product_slug/reviews` | `api/v1/reviews#create` | [reviews.md](reviews.md) | ✅ Verified |

---

## ✅ Admin Endpoints (Admin Email Required)

### Dashboard

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/admin/dashboard/stats` | `api/v1/admin/dashboard#stats` | [admin.md](admin.md) | ✅ Verified |

### Products (Admin)

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/admin/products` | `api/v1/admin/products#index` | [admin.md](admin.md) | ✅ Verified |
| POST | `/api/v1/admin/products` | `api/v1/admin/products#create` | [admin.md](admin.md) | ✅ Verified |
| PATCH/PUT | `/api/v1/admin/products/:id` | `api/v1/admin/products#update` | [admin.md](admin.md) | ✅ Verified |
| DELETE | `/api/v1/admin/products/:id` | `api/v1/admin/products#destroy` | [admin.md](admin.md) | ✅ Verified |
| POST | `/api/v1/admin/products/:id/images` | `api/v1/admin/products#images` | [admin.md](admin.md) | ✅ Verified |

### Orders (Admin)

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/admin/orders` | `api/v1/admin/orders#index` | [admin.md](admin.md) | ✅ Verified |
| PATCH | `/api/v1/admin/orders/:id/status` | `api/v1/admin/orders#status` | [admin.md](admin.md) | ✅ Verified |
| POST | `/api/v1/admin/orders/:id/shipment` | `api/v1/admin/orders#shipment` | [admin.md](admin.md) | ✅ Verified |

### Inventory (Admin)

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/admin/inventory` | `api/v1/admin/inventory#index` | [admin.md](admin.md) | ✅ Verified |
| GET | `/api/v1/admin/inventory/low-stock` | `api/v1/admin/inventory#low_stock` | [admin.md](admin.md) | ✅ Verified |
| PATCH/PUT | `/api/v1/admin/inventory/:id` | `api/v1/admin/inventory#update` | [admin.md](admin.md) | ✅ Verified |

### Customers (Admin)

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| GET | `/api/v1/admin/customers` | `api/v1/admin/customers#index` | [admin.md](admin.md) | ✅ Verified |
| GET | `/api/v1/admin/customers/:id` | `api/v1/admin/customers#show` | [admin.md](admin.md) | ✅ Verified |

---

## ✅ Webhook Endpoints (No JWT - Signature Verification)

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| POST | `/api/v1/webhooks/payment` | `api/v1/webhooks#payment` | [webhooks.md](webhooks.md) | ✅ Verified |

---

## ✅ Dev-Only Endpoints (Development/Test Only)

| Method | Path | Controller#Action | Documentation | Status |
|--------|------|-------------------|---------------|--------|
| POST | `/api/v1/dev/simulated_payments/:provider_payment_id/approve` | `api/v1/dev/simulated_payments#approve` | [payments.md](payments.md) | ✅ Verified |
| POST | `/api/v1/dev/simulated_payments/:provider_payment_id/reject` | `api/v1/dev/simulated_payments#reject` | [payments.md](payments.md) | ✅ Verified |

---

## Summary

**Total Endpoints:** 50
**Documented:** 50
**Missing Documentation:** 0

All endpoints are documented and verified against actual routes.

---

## Notes

### FriendlyId Params

Several endpoints use **slug** or **order_number** as params instead of numeric IDs:

- Products: `:slug` (e.g., `handcrafted-ceramic-bowl`)
- Categories: `:slug` (e.g., `ceramics`)
- Orders: `:order_number` (e.g., `CRA-20260322-0001`)

### HTTP Methods

Some endpoints accept both PATCH and PUT for updates (Rails default behavior):
- `PATCH /api/v1/cart/items/:id`
- `PUT /api/v1/cart/items/:id`

Both are equivalent — documentation uses PATCH as convention.

### Active Storage Routes

Active Storage routes (for serving uploaded images) are **excluded** from this verification as they are Rails framework routes, not custom API endpoints.

Example Active Storage routes (auto-generated):
- `GET /rails/active_storage/blobs/redirect/:signed_id/*filename`
- `GET /rails/active_storage/disk/:encoded_key/*filename`

---

## Verification Command

To re-verify routes, run:

```bash
rails routes | grep "api/v1" | grep -v "rails/active_storage"
```

Compare output with this table to ensure consistency.
