# Module 1: Rails Foundation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up the Rails API project with all foundational gems, testing infrastructure (RSpec), JWT authentication middleware, CORS, error handling, and API response conventions — so that all subsequent modules can build on a solid, tested base.

**Architecture:** Rails 8 API-only app connecting to Supabase PostgreSQL. JWT middleware verifies tokens from Better Auth's JWKS endpoint. All responses follow a consistent JSON format. RSpec + FactoryBot for testing.

**Tech Stack:** Rails 8.1, RSpec 8, FactoryBot, Faker, rack-cors, jwt gem, faraday, pagy, jsonapi-serializer, friendly_id, aasm, bullet, annotate

**Spec reference:** `craftitapp/docs/superpowers/specs/2026-03-21-backend-architecture-design.md`

---

## File Structure

```
craftit-api/
├── Gemfile                                    # MODIFY — add all required gems
├── .rspec                                     # CREATE (via generator)
├── spec/
│   ├── spec_helper.rb                         # CREATE (via generator)
│   ├── rails_helper.rb                        # CREATE (via generator, then configure)
│   └── support/
│       ├── factory_bot.rb                     # CREATE — FactoryBot config
│       └── request_helpers.rb                 # CREATE — shared JSON helpers for request specs
├── config/
│   ├── initializers/
│   │   ├── cors.rb                            # MODIFY — enable and configure rack-cors
│   │   ├── jwt_auth.rb                        # CREATE — JWT configuration (JWKS URL, algorithm)
│   │   └── pagy.rb                            # CREATE — pagy pagination defaults
│   └── routes.rb                              # MODIFY — add API v1 namespace structure
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb          # MODIFY — add error handling, JSON response helpers
│   │   └── api/v1/
│   │       └── base_controller.rb             # CREATE — base for all v1 controllers
│   └── middleware/
│       └── jwt_authentication.rb              # CREATE — JWT verification middleware (but not wired globally yet)
├── lib/
│   └── middleware/                             # Note: app/middleware preferred in Rails 8 with autoload_lib
└── .rubocop.yml                               # MODIFY — add RSpec cops
```

---

## Task 1: Add Required Gems to Gemfile

**Files:**
- Modify: `Gemfile`

- [ ] **Step 1: Add production gems to Gemfile**

Open `Gemfile` and add the following gems. Uncomment `rack-cors` (already present but commented). Add the rest after the existing gems:

```ruby
# Uncomment the existing rack-cors line:
gem "rack-cors"

# Add these after the existing gems:

# JSON serialization
gem "jsonapi-serializer"

# Pagination
gem "pagy", "~> 9"

# JWT verification
gem "jwt", "~> 2.10"

# HTTP client (for JWKS fetching)
gem "faraday", "~> 2.12"

# Slugs
gem "friendly_id", "~> 5.5"

# State machines (orders, shipments)
gem "aasm", "~> 5.5"
```

- [ ] **Step 2: Add development/test gems**

In the `group :development, :test` block, add:

```ruby
group :development, :test do
  # existing gems...

  # Testing
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails"
  gem "faker"

  # N+1 detection
  gem "bullet"
end
```

- [ ] **Step 3: Add development-only gems**

Add a new development-only group:

```ruby
group :development do
  # Schema annotations in model files
  gem "annotate"
end
```

- [ ] **Step 4: Run bundle install**

Run: `bundle install`
Expected: All gems install successfully, `Gemfile.lock` updated.

- [ ] **Step 5: Commit**

```bash
git add Gemfile Gemfile.lock
git commit -m "feat: add required gems for API foundation

Add rspec-rails, factory_bot_rails, faker, rack-cors, jwt, faraday,
jsonapi-serializer, pagy, friendly_id, aasm, bullet, and annotate."
```

---

## Task 2: Set Up RSpec and Remove Minitest

**Files:**
- Remove: `test/` directory (Minitest scaffold)
- Create: `.rspec`, `spec/spec_helper.rb`, `spec/rails_helper.rb` (via generator)
- Create: `spec/support/factory_bot.rb`
- Create: `spec/support/request_helpers.rb`

- [ ] **Step 1: Generate RSpec configuration**

Run: `rails generate rspec:install`
Expected: Creates `.rspec`, `spec/spec_helper.rb`, `spec/rails_helper.rb`

- [ ] **Step 2: Remove Minitest directory**

Run: `rm -rf test/`
Expected: `test/` directory removed entirely.

- [ ] **Step 3: Configure Rails generators to use RSpec and FactoryBot**

Add to `config/application.rb` inside the `CraftitApi::Application` class, after `config.api_only = true`:

```ruby
    # Use RSpec and FactoryBot for generators
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: false,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
      g.factory_bot dir: "spec/factories"
    end
```

- [ ] **Step 4: Create FactoryBot support file**

Create `spec/support/factory_bot.rb`:

```ruby
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
```

- [ ] **Step 5: Create request helpers support file**

Create `spec/support/request_helpers.rb`:

```ruby
module RequestHelpers
  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  def json_data
    json_response[:data]
  end

  def json_error
    json_response[:error]
  end

  def json_meta
    json_response[:meta]
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
```

- [ ] **Step 6: Enable support file loading in rails_helper.rb**

In `spec/rails_helper.rb`, find the commented line:

```ruby
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }
```

Uncomment it (or add it if not present):

```ruby
Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }
```

- [ ] **Step 7: Run RSpec to verify setup**

Run: `bundle exec rspec`
Expected: `0 examples, 0 failures` — clean baseline.

- [ ] **Step 8: Commit**

```bash
git add .rspec spec/ config/application.rb
git add -u test/
git commit -m "feat: replace Minitest with RSpec, configure FactoryBot

Set up RSpec with support files for FactoryBot syntax methods
and JSON request helpers. Configure generators to use RSpec
and FactoryBot. Remove default Minitest directory."
```

---

## Task 3: Configure CORS

**Files:**
- Modify: `config/initializers/cors.rb`

- [ ] **Step 1: Write a request spec for CORS headers**

Create `spec/requests/cors_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "CORS", type: :request do
  it "allows requests from the configured origin" do
    get "/up", headers: {
      "Origin" => "http://localhost:3000",
      "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "GET"
    }

    expect(response.headers["Access-Control-Allow-Origin"]).to eq("http://localhost:3000")
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/cors_spec.rb`
Expected: FAIL — no CORS headers in response.

- [ ] **Step 3: Configure CORS initializer**

Replace the contents of `config/initializers/cors.rb`:

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("ALLOWED_ORIGINS", "http://localhost:3000").split(",")

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: false,
      max_age: 3600
  end
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bundle exec rspec spec/requests/cors_spec.rb`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add config/initializers/cors.rb spec/requests/cors_spec.rb
git commit -m "feat: configure CORS for frontend origin

Enable rack-cors with configurable ALLOWED_ORIGINS env var,
defaulting to localhost:3000 for development."
```

---

## Task 4: Set Up Consistent API Response Format and Error Handling

**Files:**
- Modify: `app/controllers/application_controller.rb`
- Create: `app/controllers/api/v1/base_controller.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Write request spec for error handling**

Create `spec/requests/api/v1/health_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "API V1 Health", type: :request do
  describe "GET /api/v1/health" do
    it "returns ok status with consistent response format" do
      get "/api/v1/health"

      expect(response).to have_http_status(:ok)
      expect(json_data).to eq({ status: "ok" })
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/requests/api/v1/health_spec.rb`
Expected: FAIL — route and controller do not exist.

- [ ] **Step 3: Add response helpers to ApplicationController**

Replace `app/controllers/application_controller.rb`:

```ruby
class ApplicationController < ActionController::API
  private

  def render_success(data, status: :ok, meta: nil)
    body = { data: data }
    body[:meta] = meta if meta
    render json: body, status: status
  end

  def render_created(data)
    render_success(data, status: :created)
  end

  def render_error(code:, message:, status:, details: nil)
    body = { error: { code: code, message: message } }
    body[:error][:details] = details if details
    render json: body, status: status
  end

  def render_not_found(message = "Resource not found")
    render_error(code: "not_found", message: message, status: :not_found)
  end

  def render_unauthorized(message = "Unauthorized")
    render_error(code: "unauthorized", message: message, status: :unauthorized)
  end

  def render_forbidden(message = "Forbidden")
    render_error(code: "forbidden", message: message, status: :forbidden)
  end

  def render_validation_error(record)
    render_error(
      code: "validation_error",
      message: "Validation failed",
      status: :unprocessable_entity,
      details: record.errors.messages
    )
  end
end
```

- [ ] **Step 4: Create the API V1 base controller**

Run: `mkdir -p app/controllers/api/v1`

Create `app/controllers/api/v1/base_controller.rb`:

```ruby
module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
      rescue_from ActionController::ParameterMissing, with: :handle_bad_request

      private

      def handle_not_found(exception)
        render_not_found(exception.message)
      end

      def handle_record_invalid(exception)
        render_validation_error(exception.record)
      end

      def handle_bad_request(exception)
        render_error(
          code: "bad_request",
          message: exception.message,
          status: :bad_request
        )
      end
    end
  end
end
```

- [ ] **Step 5: Create a health controller for testing**

Create `app/controllers/api/v1/health_controller.rb`:

```ruby
module Api
  module V1
    class HealthController < BaseController
      def show
        render_success({ status: "ok" })
      end
    end
  end
end
```

- [ ] **Step 6: Add API V1 namespace to routes**

Replace `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"
    end
  end
end
```

- [ ] **Step 7: Run test to verify it passes**

Run: `bundle exec rspec spec/requests/api/v1/health_spec.rb`
Expected: PASS

- [ ] **Step 8: Add error handling specs**

Create `spec/requests/api/v1/error_handling_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "API V1 Error Handling", type: :request do
  describe "404 for unknown routes within API namespace" do
    it "returns not found for non-existent API routes" do
      get "/api/v1/nonexistent"

      expect(response).to have_http_status(:not_found)
    end
  end
end
```

- [ ] **Step 9: Run all specs**

Run: `bundle exec rspec`
Expected: All specs pass.

- [ ] **Step 10: Commit**

```bash
git add app/controllers/ config/routes.rb spec/requests/
git commit -m "feat: add API v1 namespace with consistent response format

Add response helpers (render_success, render_error, etc.) to
ApplicationController. Create Api::V1::BaseController with
rescue_from handlers. Add health endpoint at /api/v1/health."
```

---

## Task 5: Implement JWT Authentication Middleware

**Files:**
- Create: `config/initializers/jwt_auth.rb`
- Create: `app/middleware/jwt_authentication.rb`
- Create: `spec/middleware/jwt_authentication_spec.rb`

- [ ] **Step 1: Create JWT configuration initializer**

Create `config/initializers/jwt_auth.rb`:

```ruby
Rails.application.config.jwt = ActiveSupport::OrderedOptions.new
Rails.application.config.jwt.jwks_url = ENV.fetch("JWKS_URL", "http://localhost:3000/api/auth/jwks")
Rails.application.config.jwt.algorithm = ENV.fetch("JWT_ALGORITHM", "RS256")
Rails.application.config.jwt.issuer = ENV.fetch("JWT_ISSUER", nil)
Rails.application.config.jwt.jwks_cache_ttl = ENV.fetch("JWKS_CACHE_TTL", 3600).to_i
```

- [ ] **Step 2: Write middleware spec**

Create `spec/middleware/jwt_authentication_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe JwtAuthentication do
  let(:app) { ->(env) { [ 200, env, "OK" ] } }
  let(:middleware) { described_class.new(app) }

  describe "#call" do
    context "when no Authorization header is present" do
      it "passes through without setting auth_user_id" do
        env = Rack::MockRequest.env_for("/api/v1/cart")
        status, response_env, = middleware.call(env)

        expect(status).to eq(200)
        expect(response_env["auth_user_id"]).to be_nil
      end
    end

    context "when Authorization header has invalid format" do
      it "passes through without setting auth_user_id" do
        env = Rack::MockRequest.env_for(
          "/api/v1/cart",
          "HTTP_AUTHORIZATION" => "InvalidToken"
        )
        status, response_env, = middleware.call(env)

        expect(status).to eq(200)
        expect(response_env["auth_user_id"]).to be_nil
      end
    end
  end
end
```

- [ ] **Step 3: Run test to verify it fails**

Run: `bundle exec rspec spec/middleware/jwt_authentication_spec.rb`
Expected: FAIL — `JwtAuthentication` class does not exist.

- [ ] **Step 4: Implement JWT authentication middleware**

Create `app/middleware/jwt_authentication.rb`:

```ruby
class JwtAuthentication
  BEARER_PATTERN = /\ABearer\s+(.+)\z/i

  def initialize(app)
    @app = app
  end

  def call(env)
    token = extract_token(env)

    if token
      payload = decode_token(token)
      env["auth_user_id"] = payload&.dig("sub") if payload
    end

    @app.call(env)
  end

  private

  def extract_token(env)
    auth_header = env["HTTP_AUTHORIZATION"]
    return nil unless auth_header

    match = auth_header.match(BEARER_PATTERN)
    match&.[](1)
  end

  def decode_token(token)
    jwks = fetch_jwks
    return nil unless jwks

    decoded = JWT.decode(
      token,
      nil,
      true,
      {
        algorithms: [ jwt_config.algorithm ],
        jwks: jwks,
        iss: jwt_config.issuer,
        verify_iss: jwt_config.issuer.present?
      }
    )
    decoded.first
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError => e
    Rails.logger.warn("JWT decode failed: #{e.message}")
    nil
  end

  def fetch_jwks
    @jwks = nil if jwks_cache_expired?

    @jwks ||= begin
      response = Faraday.get(jwt_config.jwks_url)
      if response.success?
        @jwks_fetched_at = Time.current
        JSON.parse(response.body)
      end
    rescue Faraday::Error => e
      Rails.logger.error("JWKS fetch failed: #{e.message}")
      nil
    end
  end

  def jwks_cache_expired?
    return true unless @jwks_fetched_at
    Time.current - @jwks_fetched_at > jwt_config.jwks_cache_ttl
  end

  def jwt_config
    Rails.application.config.jwt
  end
end
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bundle exec rspec spec/middleware/jwt_authentication_spec.rb`
Expected: PASS

- [ ] **Step 6: Register middleware in application config**

Add to `config/application.rb`, inside the `CraftitApi::Application` class:

```ruby
    # JWT authentication middleware — extracts auth_user_id from Bearer token
    config.middleware.use JwtAuthentication
```

- [ ] **Step 7: Add authenticate! method to BaseController**

Add to `app/controllers/api/v1/base_controller.rb`, inside the private section:

```ruby
      def current_auth_user_id
        request.env["auth_user_id"]
      end

      def authenticate!
        render_unauthorized unless current_auth_user_id
      end
```

- [ ] **Step 8: Run all specs**

Run: `bundle exec rspec`
Expected: All specs pass.

- [ ] **Step 9: Commit**

```bash
git add config/initializers/jwt_auth.rb app/middleware/ spec/middleware/ config/application.rb app/controllers/api/v1/base_controller.rb
git commit -m "feat: add JWT authentication middleware

Implement JwtAuthentication middleware that extracts Bearer tokens,
verifies against JWKS endpoint, and sets auth_user_id in the request
env. Add authenticate! and current_auth_user_id to BaseController.
JWKS responses are cached with configurable TTL."
```

---

## Task 6: Configure Pagy Pagination

**Files:**
- Create: `config/initializers/pagy.rb`

- [ ] **Step 1: Create Pagy initializer**

Create `config/initializers/pagy.rb`:

```ruby
# frozen_string_literal: true

# Pagy default configuration
# See https://ddnexus.github.io/pagy/docs/api/pagy/#variables

Pagy::DEFAULT[:limit] = 20
Pagy::DEFAULT[:size] = 7
```

- [ ] **Step 2: Include Pagy in BaseController**

Add to the top of `app/controllers/api/v1/base_controller.rb`, inside the class:

```ruby
      include Pagy::Backend
```

Add a pagination helper to the private section:

```ruby
      def pagination_meta(pagy)
        {
          page: pagy.page,
          limit: pagy.limit,
          total_pages: pagy.pages,
          total_count: pagy.count
        }
      end
```

- [ ] **Step 3: Run all specs**

Run: `bundle exec rspec`
Expected: All specs pass.

- [ ] **Step 4: Commit**

```bash
git add config/initializers/pagy.rb app/controllers/api/v1/base_controller.rb
git commit -m "feat: configure Pagy pagination with defaults

Set default page size to 20. Include Pagy::Backend in BaseController
with pagination_meta helper for consistent response format."
```

---

## Task 7: Configure Bullet (N+1 Detection) and Annotate

**Files:**
- Create: `config/environments/development.rb` (modify)
- Modify: `Rakefile` (for annotate)

- [ ] **Step 1: Configure Bullet in development environment**

Add to `config/environments/development.rb`, inside the `Rails.application.configure` block:

```ruby
  # Bullet N+1 query detection
  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
    Bullet.add_footer = false
  end
```

- [ ] **Step 2: Generate annotate configuration**

Run: `rails generate annotate:install`
Expected: Creates `lib/tasks/auto_annotate_models.rake`

- [ ] **Step 3: Commit**

```bash
git add config/environments/development.rb lib/tasks/auto_annotate_models.rake
git commit -m "feat: configure Bullet N+1 detection and annotate

Enable Bullet logging in development. Set up annotate gem
to auto-annotate model files with schema comments."
```

---

## Task 8: Update CI to Use RSpec

**Files:**
- Modify: `.github/workflows/ci.yml`

- [ ] **Step 1: Update test command in CI**

In `.github/workflows/ci.yml`, change the test step's run command from:

```yaml
run: bin/rails db:test:prepare test
```

to:

```yaml
run: bin/rails db:test:prepare && bundle exec rspec
```

- [ ] **Step 2: Run RSpec locally to verify**

Run: `bundle exec rspec`
Expected: All specs pass.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: update test command to use RSpec instead of Minitest"
```

---

## Task 9: Add RuboCop RSpec Configuration

**Files:**
- Modify: `Gemfile`
- Modify: `.rubocop.yml`

- [ ] **Step 1: Add rubocop-rspec gem**

Add to the `group :development, :test` block in `Gemfile`:

```ruby
  gem "rubocop-rspec", require: false
```

- [ ] **Step 2: Run bundle install**

Run: `bundle install`

- [ ] **Step 3: Update RuboCop configuration**

Replace `.rubocop.yml`:

```yaml
# Omakase Ruby styling for Rails
inherit_gem: { rubocop-rails-omakase: rubocop.yml }

require:
  - rubocop-rspec

# RSpec
RSpec:
  Enabled: true

RSpec/ExampleLength:
  Max: 20

RSpec/MultipleExpectations:
  Max: 5

RSpec/NestedGroups:
  Max: 4
```

- [ ] **Step 4: Run RuboCop to check for issues**

Run: `bundle exec rubocop`
Expected: No offenses (or only auto-correctable ones).

- [ ] **Step 5: Auto-correct any offenses if needed**

Run: `bundle exec rubocop -A` (only if step 4 found auto-correctable offenses)

- [ ] **Step 6: Commit**

```bash
git add Gemfile Gemfile.lock .rubocop.yml
git commit -m "feat: add rubocop-rspec for spec linting

Configure RuboCop with RSpec cops and reasonable limits
for example length, multiple expectations, and nesting."
```

---

## Task 10: Create Environment Configuration Template

**Files:**
- Create: `.env.example`

- [ ] **Step 1: Create .env.example with all required env vars**

Create `.env.example`:

```bash
# Database
POSTGRES_URL=postgres://postgres:postgres@localhost:5432/craftit_api_development

# CORS — comma-separated origins allowed to call this API
ALLOWED_ORIGINS=http://localhost:3000

# JWT Authentication (Better Auth JWKS)
JWKS_URL=http://localhost:3000/api/auth/jwks
JWT_ALGORITHM=RS256
# JWT_ISSUER=  # Optional: set if Better Auth configures an issuer

# JWKS cache TTL in seconds (default: 3600)
# JWKS_CACHE_TTL=3600

# Admin email (used by Rails to identify admin users)
ADMIN_EMAIL=admin@craftitapp.com
```

- [ ] **Step 2: Add .env to .gitignore if not already present**

Check if `.env` is in `.gitignore`. If not, add:

```
.env
.env.local
```

- [ ] **Step 3: Commit**

```bash
git add .env.example .gitignore
git commit -m "feat: add .env.example with all required environment variables"
```

---

## Task 11: Final Verification

- [ ] **Step 1: Run full test suite**

Run: `bundle exec rspec --format documentation`
Expected: All specs pass with descriptive output.

- [ ] **Step 2: Run RuboCop**

Run: `bundle exec rubocop`
Expected: No offenses.

- [ ] **Step 3: Run Brakeman security scan**

Run: `bundle exec brakeman --no-pager`
Expected: No warnings (or only informational notes).

- [ ] **Step 4: Verify Rails server starts**

Run: `bin/rails server -p 3001`
Then: `curl http://localhost:3001/api/v1/health`
Expected: `{"data":{"status":"ok"}}`
Stop the server.

- [ ] **Step 5: Commit any remaining changes**

```bash
git status
# If any unstaged changes exist, review and commit them
```
