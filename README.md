# CraftIt API

Rails 8 API-only backend for the CraftItApp e-commerce platform.

**Purpose:** Provides REST API for handcrafted product marketplace with inventory management, order processing, and payment integration.

**Tech Stack:** Rails 8.1, PostgreSQL 17, JWT authentication (Better Auth JWKS), ActiveJob, RSpec, Docker

---

## Quick Start

### Prerequisites

- Ruby 3.3+
- PostgreSQL 17+ (via Docker or local install)
- Node.js (for frontend integration)

### Setup

1. **Clone and install dependencies:**

```bash
bundle install
```

2. **Start PostgreSQL (Docker):**

```bash
docker compose up -d
```

This starts:
- **PostgreSQL** on `localhost:5432`
- **Adminer** (DB UI) on `http://localhost:8080`

3. **Configure environment:**

```bash
cp .env.example .env
# Edit .env with your configuration (see Environment Variables section)
```

4. **Setup database:**

```bash
bin/rails db:prepare
```

5. **Run the server:**

```bash
bin/rails server -p 3001
```

API available at `http://localhost:3001`

---

## Architecture Overview

```
┌─────────────┐     JWT      ┌────────────────┐    HTTP    ┌──────────────┐
│   Next.js   │─────────────>│   Rails API    │───────────>│  PostgreSQL  │
│ (Better Auth│     JWKS     │  (craftit-api) │            │              │
└─────────────┘              └────────────────┘            └──────────────┘
                                     │
                                     │ Webhooks
                                     ▼
                             ┌────────────────┐
                             │ Payment Provider│
                             │ (Simulated /   │
                             │  MercadoPago)  │
                             └────────────────┘
```

**Authentication:**
- JWT tokens issued by Better Auth (Next.js frontend)
- Rails verifies JWT against Better Auth JWKS endpoint
- No password storage in Rails (delegated to Better Auth)

**Payment Processing:**
- Strategy pattern with pluggable providers
- Default: SimulatedProvider (dev/test)
- Production: MercadoPago, Stripe (drop-in replacement)

**Data Flow:**
- Next.js BFF layer proxies authenticated requests to Rails
- Rails handles business logic, inventory, orders, payments
- PostgreSQL stores all application data

---

## Documentation

### API Documentation

📖 **[API v1 Overview](docs/api/v1/overview.md)** — Start here for API usage

**Endpoints by Category:**

| Category | Documentation |
|----------|---------------|
| Authentication | [auth.md](docs/api/v1/auth.md) |
| Products (Public) | [products.md](docs/api/v1/products.md) |
| Categories (Public) | [categories.md](docs/api/v1/categories.md) |
| Cart (Authenticated) | [cart.md](docs/api/v1/cart.md) |
| Orders (Authenticated) | [orders.md](docs/api/v1/orders.md) |
| Payments (Authenticated) | [payments.md](docs/api/v1/payments.md) |
| Profile (Authenticated) | [profile.md](docs/api/v1/profile.md) |
| Admin API | [admin.md](docs/api/v1/admin.md) |
| Webhooks | [webhooks.md](docs/api/v1/webhooks.md) |

### Feature Documentation

Business logic and workflows:

- **[Payment Simulation](docs/feature/payment-simulation.md)** — Strategy pattern payment architecture
- **[Order Checkout Flow](docs/feature/order-checkout.md)** — Cart → Order → Payment → Fulfillment
- **[Inventory Management](docs/feature/inventory-management.md)** — Stock reservation and confirmation

### Implementation Plans

📝 **Historical reference** — modular implementation plans used during development:

- [IMPLEMENTATION_PLANS_README.md](../IMPLEMENTATION_PLANS_README.md) — Overview of all modules
- [Module plans](docs/superpowers/plans/) — Step-by-step TDD implementation guides

⚠️ **Note:** Plans represent the original design. For actual implementation details, refer to code and API documentation above.

---

## Environment Variables

Copy `.env.example` to `.env` and configure:

### Database

```bash
DATABASE_URL=postgres://postgres:postgres@localhost:5432/craftit_api_development
```

**Production:** Use Supabase PostgreSQL or managed Postgres (same schema compatibility).

### CORS

```bash
ALLOWED_ORIGINS=http://localhost:3000
```

**Production:** Update with your frontend domain.

### JWT Authentication

```bash
JWKS_URL=http://localhost:3000/api/auth/jwks
JWT_ALGORITHM=RS256
# JWT_ISSUER=  # Optional
JWKS_CACHE_TTL=3600  # seconds
```

### Admin Access

```bash
ADMIN_EMAIL=admin@craftitapp.com
```

Admin user is identified by matching JWT email claim with this value.

### Payment Provider

```bash
PAYMENT_PROVIDER=simulated
SIMULATED_PAYMENT_AUTO_APPROVE_DELAY=30  # seconds
```

**For production (MercadoPago):**

```bash
PAYMENT_PROVIDER=mercadopago
MERCADOPAGO_ACCESS_TOKEN=your_access_token
MERCADOPAGO_WEBHOOK_SECRET=your_webhook_secret
```

See [Payment Simulation](docs/feature/payment-simulation.md) for migration guide.

---

## Key Features

### 🔐 JWT Authentication (Better Auth Integration)

- JWKS-based JWT verification
- No password storage in Rails
- Auto-creates `CustomerProfile` on first authenticated request
- Admin authorization via email matching

**Docs:** [auth.md](docs/api/v1/auth.md)

### 🛒 Shopping Cart & Checkout

- Guest cart merge via `/cart/sync` endpoint
- Inventory reservation on order creation
- 30-minute reservation timeout (automated cleanup)

**Docs:** [cart.md](docs/api/v1/cart.md), [orders.md](docs/api/v1/orders.md)

### 💳 Payment Processing (Strategy Pattern)

- Pluggable payment providers (Simulated, MercadoPago, Stripe)
- Auto-approval and manual approval modes (simulated)
- Webhook processing for real providers
- Background jobs for auto-approval and reservation timeout

**Docs:** [payments.md](docs/api/v1/payments.md), [payment-simulation.md](docs/feature/payment-simulation.md)

### 📦 Inventory Management

- Stock and reserved stock tracking
- Reserve → Confirm → Release flow
- Low-stock alerts (admin)

**Docs:** [inventory-management.md](docs/feature/inventory-management.md)

### 🖼️ Product Images (Active Storage)

- Admin upload via multipart/form-data
- Local disk storage (dev)
- Ready for S3/Supabase storage (production)

**Docs:** [admin.md](docs/api/v1/admin.md)

### 🧪 Testing Infrastructure

- RSpec + FactoryBot
- Request specs with authenticated helpers
- Test JWT bypass for fast integration tests

**Specs:** `spec/requests/`, `spec/services/`, `spec/models/`

---

## Database

### PostgreSQL via Docker

Start local Postgres + Adminer:

```bash
docker compose up -d
```

**Adminer UI:** http://localhost:8080

- **System:** PostgreSQL
- **Server:** `postgres`
- **Username:** `postgres`
- **Password:** `postgres`
- **Database:** `craftit_api_development` (or `craftit_api_test`)

### Migrations

```bash
bin/rails db:migrate
```

### Seed Data

```bash
bin/rails db:seed
```

**Includes:**
- Sample categories (Ceramics, Textiles, Jewelry, etc.)
- Sample products with inventory
- Admin user (via ADMIN_EMAIL)
- Sample orders and reviews

---

## Testing

### Run All Tests

```bash
bundle exec rspec
```

### Run Specific Test Suite

```bash
bundle exec rspec spec/requests/api/v1/products_spec.rb
bundle exec rspec spec/services/payment_service_spec.rb
```

### Linting (RuboCop)

```bash
bundle exec rubocop
```

**Auto-fix:**

```bash
bundle exec rubocop -A
```

---

## Development Tools

### Adminer (Database UI)

Web-based Postgres client: http://localhost:8080

### Bullet (N+1 Detection)

Enabled in development — logs N+1 queries to console.

**Location:** `config/environments/development.rb`

### Annotate (Schema Comments)

Auto-adds schema comments to models:

```bash
bundle exec annotate
```

---

## Project Structure

```
craftit-api/
├── app/
│   ├── controllers/api/v1/       # API endpoints (public, authenticated, admin)
│   ├── jobs/                     # Background jobs (ActiveJob)
│   ├── middleware/               # JWT authentication middleware
│   ├── models/                   # ActiveRecord models
│   ├── serializers/              # JSON serializers (fast_jsonapi)
│   └── services/                 # Business logic (OrderService, PaymentService, etc.)
├── config/
│   ├── routes.rb                 # API routes
│   └── initializers/             # Rails configuration
├── db/
│   ├── migrate/                  # Database migrations
│   └── seeds.rb                  # Seed data
├── docs/
│   ├── api/v1/                   # API endpoint documentation
│   ├── feature/                  # Feature/workflow documentation
│   └── superpowers/plans/        # Implementation plans (historical)
├── spec/                         # RSpec tests
├── docker-compose.yml            # Postgres + Adminer
├── .env.example                  # Environment variable template
└── README.md                     # This file
```

---

## Deployment

### Production Checklist

- [ ] Update `ALLOWED_ORIGINS` with production frontend URL
- [ ] Configure production database (Supabase or managed Postgres)
- [ ] Set `PAYMENT_PROVIDER` to real provider (e.g., `mercadopago`)
- [ ] Add payment provider credentials (access tokens, webhook secrets)
- [ ] Configure Active Storage for S3 or Supabase Storage
- [ ] Set up background job processor (Sidekiq, SolidQueue)
- [ ] Enable SSL for API endpoint
- [ ] Configure monitoring (Sentry, New Relic, etc.)
- [ ] Set up cron job for `ReservationTimeoutJob`

### Recommended Services

- **Database:** Supabase PostgreSQL (same family as dev Postgres)
- **File Storage:** Supabase Storage or AWS S3
- **Hosting:** Fly.io, Render, Heroku, AWS ECS
- **Background Jobs:** Sidekiq (Redis-backed) or SolidQueue (Postgres-backed)

---

## Contributing

### Git Workflow

This repo uses **feature branches** and **conventional commits**.

**Branch naming:**
```
feature/payment-simulation
fix/cart-sync-bug
```

**Commit message format:**
```
feat: add payment simulation layer
fix: resolve cart sync duplicate items
docs: update API documentation
```

### Code Style

- Follow Rails conventions
- Use RuboCop for linting
- Write tests first (TDD workflow)
- Keep controllers thin (delegate to services)

---

## License

(Add license information here)

---

## Support

For issues or questions:
- Check [API Documentation](docs/api/v1/overview.md)
- Review [Implementation Plans](../IMPLEMENTATION_PLANS_README.md)
- Open an issue on GitHub

---

## Related Projects

- **[craftitapp](../craftitapp/)** — Next.js frontend with Better Auth
- **[IMPLEMENTATION_PLANS_README.md](../IMPLEMENTATION_PLANS_README.md)** — Modular implementation guide
