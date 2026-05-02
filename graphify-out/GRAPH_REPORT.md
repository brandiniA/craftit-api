# Graph Report - .  (2026-05-01)

## Corpus Check
- Corpus is ~38,732 words - fits in a single context window. You may not need a graph.

## Summary
- 289 nodes · 369 edges · 36 communities detected
- Extraction: 66% EXTRACTED · 34% INFERRED · 0% AMBIGUOUS · INFERRED: 125 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Products API Layer|Products API Layer]]
- [[_COMMUNITY_Admin Dashboard & Inventory|Admin Dashboard & Inventory]]
- [[_COMMUNITY_Infrastructure & Config|Infrastructure & Config]]
- [[_COMMUNITY_Customers & Categories API|Customers & Categories API]]
- [[_COMMUNITY_Payment & Webhook Processing|Payment & Webhook Processing]]
- [[_COMMUNITY_Orders & Auth Controllers|Orders & Auth Controllers]]
- [[_COMMUNITY_JWT Auth & API Foundation|JWT Auth & API Foundation]]
- [[_COMMUNITY_JWT Middleware|JWT Middleware]]
- [[_COMMUNITY_Payment Provider Interface|Payment Provider Interface]]
- [[_COMMUNITY_Order Line Items|Order Line Items]]
- [[_COMMUNITY_Cart Items|Cart Items]]
- [[_COMMUNITY_Mailer|Mailer]]
- [[_COMMUNITY_Background Jobs|Background Jobs]]
- [[_COMMUNITY_Payment Model|Payment Model]]
- [[_COMMUNITY_Customer Profile Model|Customer Profile Model]]
- [[_COMMUNITY_Address Model|Address Model]]
- [[_COMMUNITY_Review Model|Review Model]]
- [[_COMMUNITY_Category Model|Category Model]]
- [[_COMMUNITY_Wishlist Items|Wishlist Items]]
- [[_COMMUNITY_Shipment Model|Shipment Model]]
- [[_COMMUNITY_Application Record|Application Record]]
- [[_COMMUNITY_Product Images|Product Images]]
- [[_COMMUNITY_Review Serializer|Review Serializer]]
- [[_COMMUNITY_Category Serializer|Category Serializer]]
- [[_COMMUNITY_Order Detail Serializer|Order Detail Serializer]]
- [[_COMMUNITY_Profile Serializer|Profile Serializer]]
- [[_COMMUNITY_Shipment Serializer|Shipment Serializer]]
- [[_COMMUNITY_Order Serializer|Order Serializer]]
- [[_COMMUNITY_Product Detail Serializer|Product Detail Serializer]]
- [[_COMMUNITY_Order Item Serializer|Order Item Serializer]]
- [[_COMMUNITY_Cart Item Serializer|Cart Item Serializer]]
- [[_COMMUNITY_Address Serializer|Address Serializer]]
- [[_COMMUNITY_Product Serializer|Product Serializer]]
- [[_COMMUNITY_Wishlist Serializer|Wishlist Serializer]]
- [[_COMMUNITY_Bundler Audit Config|Bundler Audit Config]]
- [[_COMMUNITY_Locales|Locales]]

## God Nodes (most connected - your core abstractions)
1. `Order` - 13 edges
2. `CraftIt API` - 10 edges
3. `Product` - 9 edges
4. `BaseController` - 9 edges
5. `process_webhook!()` - 9 edges
6. `JwtAuthentication` - 8 edges
7. `Inventory` - 8 edges
8. `ApplicationController` - 8 edges
9. `Payment Simulation Feature` - 8 edges
10. `ProductsController` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Inventory model (plan)` --semantically_similar_to--> `Inventory Management`  [INFERRED] [semantically similar]
  docs/superpowers/plans/2026-03-22-module-2a-data-model-core.md → README.md
- `InventoryService` --implements--> `Inventory Management`  [INFERRED]
  docs/superpowers/plans/2026-03-22-module-4b-authenticated-api-orders.md → README.md
- `CraftIt API` --references--> `API v1 Overview`  [EXTRACTED]
  README.md → docs/api/v1/overview.md
- `postgres service (Docker)` --implements--> `PostgreSQL 17`  [INFERRED]
  docker-compose.yml → README.md
- `SimulatedProvider` --implements--> `BaseProvider (interface)`  [INFERRED]
  README.md → docs/feature/payment-simulation.md

## Hyperedges (group relationships)
- **Payment Flow: Service + Strategy Providers + Jobs** — payments_payment_service, readme_simulated_provider, payments_auto_approve_job [EXTRACTED 0.95]
- **Authentication Pipeline: JWKS + Middleware + BaseController** — auth_jwks_endpoint, auth_jwt_middleware, auth_base_controller [EXTRACTED 0.95]
- **Core Data Models: Product + Category + Inventory** — plan_module2a_product, plan_module2a_category, plan_module2a_inventory [INFERRED 0.85]

## Communities

### Community 0 - "Products API Layer"
Cohesion: 0.08
Nodes (7): ProductsController, AddressesController, CartController, HealthController, ProfileController, ShipmentsController, WishlistController

### Community 1 - "Admin Dashboard & Inventory"
Cohesion: 0.07
Nodes (9): DashboardController, InventoryController, ReservationTimeoutJob, Inventory, Product, InsufficientStockError, InventoryService, EmptyCartError (+1 more)

### Community 2 - "Infrastructure & Config"
Cohesion: 0.11
Nodes (30): config/database.yml, config/storage.yml, adminer service (Docker), postgres service (Docker), BaseProvider (interface), Payment Simulation Feature, ReservationTimeoutJob, Payments API (+22 more)

### Community 3 - "Customers & Categories API"
Cohesion: 0.1
Nodes (6): CustomersController, Order, CategoriesController, OrdersController, ProductsController, ReviewsController

### Community 4 - "Payment & Webhook Processing"
Cohesion: 0.09
Nodes (8): SimulatedPaymentsController, AutoApprovePaymentJob, SimulatedProvider, create_payment!(), PaymentService, process_webhook!(), PaymentsController, WebhooksController

### Community 5 - "Orders & Auth Controllers"
Cohesion: 0.11
Nodes (4): BaseController, OrdersController, ApplicationController, BaseController

### Community 6 - "JWT Auth & API Foundation"
Cohesion: 0.12
Nodes (21): Api::V1::Admin::BaseController, Api::V1::BaseController, CustomerProfile (auth bridge), Better Auth JWKS Endpoint, JwtAuthentication Middleware, API v1 Overview, CORS Configuration, JWT Authentication (overview) (+13 more)

### Community 7 - "JWT Middleware"
Cohesion: 0.24
Nodes (2): Application, JwtAuthentication

### Community 8 - "Payment Provider Interface"
Cohesion: 0.33
Nodes (3): BaseProvider, NotImplementedError, PaymentError

### Community 9 - "Order Line Items"
Cohesion: 0.67
Nodes (1): OrderItem

### Community 10 - "Cart Items"
Cohesion: 0.67
Nodes (1): CartItem

### Community 11 - "Mailer"
Cohesion: 1.0
Nodes (1): ApplicationMailer

### Community 12 - "Background Jobs"
Cohesion: 1.0
Nodes (1): ApplicationJob

### Community 13 - "Payment Model"
Cohesion: 1.0
Nodes (1): Payment

### Community 14 - "Customer Profile Model"
Cohesion: 1.0
Nodes (1): CustomerProfile

### Community 15 - "Address Model"
Cohesion: 1.0
Nodes (1): Address

### Community 16 - "Review Model"
Cohesion: 1.0
Nodes (1): Review

### Community 17 - "Category Model"
Cohesion: 1.0
Nodes (1): Category

### Community 18 - "Wishlist Items"
Cohesion: 1.0
Nodes (1): WishlistItem

### Community 19 - "Shipment Model"
Cohesion: 1.0
Nodes (1): Shipment

### Community 20 - "Application Record"
Cohesion: 1.0
Nodes (1): ApplicationRecord

### Community 21 - "Product Images"
Cohesion: 1.0
Nodes (1): ProductImage

### Community 22 - "Review Serializer"
Cohesion: 1.0
Nodes (1): ReviewSerializer

### Community 23 - "Category Serializer"
Cohesion: 1.0
Nodes (1): CategorySerializer

### Community 24 - "Order Detail Serializer"
Cohesion: 1.0
Nodes (1): OrderDetailSerializer

### Community 25 - "Profile Serializer"
Cohesion: 1.0
Nodes (1): ProfileSerializer

### Community 26 - "Shipment Serializer"
Cohesion: 1.0
Nodes (1): ShipmentSerializer

### Community 27 - "Order Serializer"
Cohesion: 1.0
Nodes (1): OrderSerializer

### Community 28 - "Product Detail Serializer"
Cohesion: 1.0
Nodes (1): ProductDetailSerializer

### Community 29 - "Order Item Serializer"
Cohesion: 1.0
Nodes (1): OrderItemSerializer

### Community 30 - "Cart Item Serializer"
Cohesion: 1.0
Nodes (1): CartItemSerializer

### Community 31 - "Address Serializer"
Cohesion: 1.0
Nodes (1): AddressSerializer

### Community 32 - "Product Serializer"
Cohesion: 1.0
Nodes (1): ProductSerializer

### Community 33 - "Wishlist Serializer"
Cohesion: 1.0
Nodes (1): WishlistItemSerializer

### Community 48 - "Bundler Audit Config"
Cohesion: 1.0
Nodes (1): config/bundler-audit.yml

### Community 49 - "Locales"
Cohesion: 1.0
Nodes (1): config/locales/en.yml

## Knowledge Gaps
- **40 isolated node(s):** `ApplicationMailer`, `ApplicationJob`, `Payment`, `CustomerProfile`, `Address` (+35 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `JWT Middleware`** (11 nodes): `jwt_authentication.rb`, `Application`, `application.rb`, `JwtAuthentication`, `.call()`, `.decode_token()`, `.extract_token()`, `.fetch_jwks()`, `.initialize()`, `.jwks_cache_expired?()`, `.jwt_config()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Order Line Items`** (3 nodes): `order_item.rb`, `OrderItem`, `.subtotal()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Cart Items`** (3 nodes): `cart_item.rb`, `CartItem`, `.subtotal()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Mailer`** (2 nodes): `application_mailer.rb`, `ApplicationMailer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Background Jobs`** (2 nodes): `application_job.rb`, `ApplicationJob`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Payment Model`** (2 nodes): `payment.rb`, `Payment`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Customer Profile Model`** (2 nodes): `customer_profile.rb`, `CustomerProfile`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Address Model`** (2 nodes): `address.rb`, `Address`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Review Model`** (2 nodes): `review.rb`, `Review`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Category Model`** (2 nodes): `category.rb`, `Category`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Wishlist Items`** (2 nodes): `wishlist_item.rb`, `WishlistItem`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Shipment Model`** (2 nodes): `shipment.rb`, `Shipment`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Application Record`** (2 nodes): `application_record.rb`, `ApplicationRecord`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Product Images`** (2 nodes): `product_image.rb`, `ProductImage`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Review Serializer`** (2 nodes): `review_serializer.rb`, `ReviewSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Category Serializer`** (2 nodes): `category_serializer.rb`, `CategorySerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Order Detail Serializer`** (2 nodes): `order_detail_serializer.rb`, `OrderDetailSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Profile Serializer`** (2 nodes): `profile_serializer.rb`, `ProfileSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Shipment Serializer`** (2 nodes): `shipment_serializer.rb`, `ShipmentSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Order Serializer`** (2 nodes): `order_serializer.rb`, `OrderSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Product Detail Serializer`** (2 nodes): `product_detail_serializer.rb`, `ProductDetailSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Order Item Serializer`** (2 nodes): `order_item_serializer.rb`, `OrderItemSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Cart Item Serializer`** (2 nodes): `cart_item_serializer.rb`, `CartItemSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Address Serializer`** (2 nodes): `address_serializer.rb`, `AddressSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Product Serializer`** (2 nodes): `product_serializer.rb`, `ProductSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Wishlist Serializer`** (2 nodes): `wishlist_item_serializer.rb`, `WishlistItemSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Bundler Audit Config`** (1 nodes): `config/bundler-audit.yml`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Locales`** (1 nodes): `config/locales/en.yml`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `process_webhook!()` connect `Payment & Webhook Processing` to `Admin Dashboard & Inventory`, `Customers & Categories API`?**
  _High betweenness centrality (0.065) - this node is a cross-community bridge._
- **Why does `Order` connect `Customers & Categories API` to `Products API Layer`, `Admin Dashboard & Inventory`, `Payment & Webhook Processing`?**
  _High betweenness centrality (0.034) - this node is a cross-community bridge._
- **Why does `Product` connect `Admin Dashboard & Inventory` to `Payment & Webhook Processing`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Are the 12 inferred relationships involving `Order` (e.g. with `.index()` and `.index()`) actually correct?**
  _`Order` has 12 INFERRED edges - model-reasoned connections that need verification._
- **Are the 5 inferred relationships involving `Product` (e.g. with `.perform()` and `.inventory_json()`) actually correct?**
  _`Product` has 5 INFERRED edges - model-reasoned connections that need verification._
- **Are the 8 inferred relationships involving `process_webhook!()` (e.g. with `.perform()` and `.payment()`) actually correct?**
  _`process_webhook!()` has 8 INFERRED edges - model-reasoned connections that need verification._
- **What connects `ApplicationMailer`, `ApplicationJob`, `Payment` to the rest of the system?**
  _40 weakly-connected nodes found - possible documentation gaps or missing edges._