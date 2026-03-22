# API v1 Overview

**Base URL:** `http://localhost:3001/api/v1`

**Production URL:** (TBD - to be configured with actual domain)

---

## Authentication

The API uses **JWT-based authentication** via Better Auth (Next.js frontend).

### For Public Endpoints

No authentication required. Examples:
- Product listing and search
- Category browsing
- Public review listing

### For Authenticated Endpoints

Include JWT token in the `Authorization` header:

```
Authorization: Bearer <jwt_token>
```

The JWT is verified against the Better Auth JWKS endpoint configured in `JWKS_URL` (.env).

**JWT Claims Required:**
- `sub` (subject) — maps to `auth_user_id`
- `email` — user email address

### For Admin Endpoints

Admin endpoints require:
1. Valid JWT authentication (as above)
2. User email must match `ADMIN_EMAIL` environment variable

**Admin authorization flow:**
- Extract `email` from JWT
- Compare with `ENV['ADMIN_EMAIL']`
- Return 403 Forbidden if mismatch

### Test Environment Only

For **test environment only**, the middleware accepts test auth headers as a bypass:

```
HTTP_AUTH_USER_ID: <user_id>
HTTP_AUTH_USER_EMAIL: <email>
```

⚠️ **Security:** This bypass is **disabled in production** via `Rails.env.test?` guard in `JwtAuthentication` middleware.

---

## Response Format

All API responses follow a consistent JSON structure.

### Success Response

```json
{
  "data": {
    // Response payload
  },
  "meta": {
    // Optional metadata (pagination, etc.)
  }
}
```

### Error Response

```json
{
  "error": {
    "code": "error_code",
    "message": "Human-readable error message"
  }
}
```

**Common Error Codes:**
- `unauthorized` (401) — Missing or invalid JWT
- `forbidden` (403) — Valid JWT but insufficient permissions
- `not_found` (404) — Resource not found
- `validation_error` (422) — Request validation failed
- `bad_request` (400) — Malformed request

---

## Pagination

List endpoints use **Pagy** for pagination.

### Query Parameters

- `page` — Page number (default: 1)
- `items` — Items per page (default: 20, max: 100)

### Response Meta

```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 20,
    "total_pages": 5,
    "total_count": 87
  }
}
```

---

## CORS

CORS is configured to allow requests from:

```
ALLOWED_ORIGINS=http://localhost:3000
```

For production, update `.env` with your frontend domain.

---

## Rate Limiting

(Not yet implemented — consider adding rack-attack for production)

---

## Endpoints Summary

| Area | Endpoints | Auth | Documentation |
|------|-----------|------|---------------|
| **Health** | `GET /health` | None | [health.md](health.md) |
| **Products** | List, Detail, Search | None | [products.md](products.md) |
| **Categories** | List, Detail | None | [categories.md](categories.md) |
| **Reviews** | List (public), Create (auth) | Mixed | [reviews.md](reviews.md) |
| **Cart** | CRUD, Sync | JWT | [cart.md](cart.md) |
| **Wishlist** | List, Add, Remove | JWT | [wishlist.md](wishlist.md) |
| **Orders** | List, Detail, Create | JWT | [orders.md](orders.md) |
| **Payments** | Initiate Payment | JWT | [payments.md](payments.md) |
| **Shipments** | View Shipment | JWT | [shipments.md](shipments.md) |
| **Profile** | View, Update | JWT | [profile.md](profile.md) |
| **Addresses** | CRUD | JWT | [addresses.md](addresses.md) |
| **Admin** | Products, Orders, Inventory, Customers, Dashboard | Admin | [admin.md](admin.md) |
| **Webhooks** | Payment Notifications | None (signature verification) | [webhooks.md](webhooks.md) |

---

## Environment Variables

See `.env.example` for all required variables.

**Key Variables:**
- `DATABASE_URL` — Postgres connection string
- `ALLOWED_ORIGINS` — CORS whitelist
- `JWKS_URL` — Better Auth JWKS endpoint (e.g., `http://localhost:3000/api/auth/jwks`)
- `JWT_ALGORITHM` — JWT algorithm (default: `RS256`)
- `ADMIN_EMAIL` — Email address for admin user
- `PAYMENT_PROVIDER` — Payment provider (default: `simulated`)

---

## Next Steps

- [Authentication Details](auth.md)
- [Public API](products.md)
- [Authenticated API](cart.md)
- [Admin API](admin.md)
- [Payment Flows](payments.md)
