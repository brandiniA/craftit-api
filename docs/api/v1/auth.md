# Authentication

The `craftit-api` backend delegates authentication to **Better Auth** (running in the Next.js frontend) and verifies JWT tokens using JWKS.

---

## Architecture Overview

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Browser   │  JWT    │  Next.js    │  JWKS   │  Rails API  │
│             ├────────>│  (Better    ├────────>│             │
│             │         │   Auth)     │         │             │
└─────────────┘         └─────────────┘         └─────────────┘
```

1. **User authenticates** with Better Auth (Next.js `/api/auth/*`)
2. Better Auth issues a **JWT** to the client
3. Client includes JWT in `Authorization: Bearer <token>` header
4. Rails middleware **verifies JWT** against Better Auth's JWKS endpoint
5. Rails extracts `auth_user_id` and `auth_user_email` from token claims

---

## JWT Verification Flow

### Middleware: `JwtAuthentication`

**Location:** `app/middleware/jwt_authentication.rb`

**Responsibilities:**
1. Extract `Bearer` token from `Authorization` header
2. Fetch JWKS from Better Auth (`JWKS_URL` env var)
3. Verify JWT signature using JWKS public key
4. Extract claims: `sub` (user ID) and `email`
5. Store in Rack env: `env['auth_user_id']`, `env['auth_user_email']`

**JWKS Caching:**
- JWKS is cached in-memory for `JWKS_CACHE_TTL` seconds (default: 3600)
- Cache invalidates automatically after TTL expires
- Reduces external requests to Better Auth

### Test Environment Bypass

For **test environment only**, the middleware accepts test headers:

```ruby
if Rails.env.test? && env["HTTP_AUTH_USER_ID"].present?
  env["auth_user_id"] = env["HTTP_AUTH_USER_ID"]
  env["auth_user_email"] = env["HTTP_AUTH_USER_EMAIL"]
  return @app.call(env)
end
```

**Usage in RSpec:**

```ruby
# spec/support/auth_helpers.rb
def authenticated_post(path, customer_profile:, params: {})
  post path,
    params: params.to_json,
    headers: {
      "HTTP_AUTH_USER_ID" => customer_profile.auth_user_id,
      "HTTP_AUTH_USER_EMAIL" => customer_profile.email || "test@example.com",
      "CONTENT_TYPE" => "application/json"
    }
end
```

⚠️ **Security:** This bypass is **disabled in production** via `Rails.env.test?` guard.

---

## Environment Variables

```bash
# JWT Authentication (Better Auth JWKS)
JWKS_URL=http://localhost:3000/api/auth/jwks
JWT_ALGORITHM=RS256
# JWT_ISSUER=  # Optional: set if Better Auth configures an issuer

# JWKS cache TTL in seconds (default: 3600)
# JWKS_CACHE_TTL=3600
```

---

## Base Controller Helpers

**Location:** `app/controllers/api/v1/base_controller.rb`

### Available Methods

#### `current_auth_user_id`
Returns the authenticated user's ID from JWT `sub` claim.

```ruby
request.env["auth_user_id"]  # => "clxxxx..."
```

#### `current_auth_user_email`
Returns the authenticated user's email from JWT `email` claim.

```ruby
request.env["auth_user_email"]  # => "user@example.com"
```

#### `current_customer_profile`
Auto-creates or finds `CustomerProfile` for the authenticated user.

```ruby
# Cached per-request
@current_customer_profile ||= CustomerProfile.find_or_create_by!(
  auth_user_id: current_auth_user_id
)
```

**Bridge to Better Auth:**
- `CustomerProfile.auth_user_id` maps to Better Auth's `user.id`
- No password or auth logic stored in Rails
- Better Auth is the source of truth for authentication

#### `authenticate!`
Renders 401 Unauthorized if no JWT is present.

```ruby
before_action :authenticate!
```

---

## Admin Authorization

**Location:** `app/controllers/api/v1/admin/base_controller.rb`

Admin endpoints require:
1. Valid JWT (via `authenticate!`)
2. Email matching `ADMIN_EMAIL` env var

```ruby
before_action :authorize_admin!

private

def authorize_admin!
  admin_email = ENV.fetch("ADMIN_EMAIL", nil)
  if admin_email.blank? || current_auth_user_email != admin_email
    render_forbidden("Admin access required")
  end
end
```

**Environment Variable:**

```bash
ADMIN_EMAIL=admin@craftitapp.com
```

⚠️ **Production Consideration:** For multi-admin support, replace email check with a role/permission system (e.g., Better Auth permissions or database roles).

---

## Error Handling

### Missing JWT (Public Endpoint)

**No error** — `current_auth_user_id` returns `nil`, `current_customer_profile` returns `nil`.

### Missing JWT (Protected Endpoint)

**Response:**
```json
{
  "error": {
    "code": "unauthorized",
    "message": "Authentication required"
  }
}
```

**HTTP Status:** `401 Unauthorized`

### Invalid JWT

**Logged:** JWT decode errors are logged but **not exposed** to the client.

**Response:** Same as missing JWT (401).

### Admin Access Denied

**Response:**
```json
{
  "error": {
    "code": "forbidden",
    "message": "Admin access required"
  }
}
```

**HTTP Status:** `403 Forbidden`

---

## JWKS Endpoint (Better Auth)

The Rails API expects Better Auth to expose a JWKS endpoint at:

```
GET http://localhost:3000/api/auth/jwks
```

**Expected Response:**

```json
{
  "keys": [
    {
      "kty": "RSA",
      "use": "sig",
      "kid": "...",
      "n": "...",
      "e": "AQAB"
    }
  ]
}
```

**Configuration:** See Next.js `craftitapp` Module 6A (Better Auth setup with JWT plugin).

---

## Troubleshooting

### 401 on all authenticated requests

- Check `JWKS_URL` is correct
- Verify Better Auth is running and serving JWKS
- Check JWT token in browser DevTools (Network → Request Headers)
- Verify JWT `sub` and `email` claims are present

### Admin endpoints return 403

- Verify `ADMIN_EMAIL` env var is set
- Check JWT `email` claim matches `ADMIN_EMAIL`
- Ensure admin user logged in with correct email

### Test environment: JWT verification fails

- Use `authenticated_post` helper with `HTTP_AUTH_USER_ID` header
- Do **not** set `Authorization: Bearer` in tests (unless testing JWT middleware itself)

---

## Related Documentation

- [Overview](overview.md)
- [Profile API](profile.md) (manages CustomerProfile)
- [Admin API](admin.md) (admin authorization)
