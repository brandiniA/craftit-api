# Graph Report - craftit-api  (2026-05-01)

## Corpus Check
- Corpus is ~48,005 words - fits in a single context window. You may not need a graph.

## Summary
- 433 nodes · 463 edges · 52 communities detected
- Extraction: 75% EXTRACTED · 25% INFERRED · 0% AMBIGUOUS · INFERRED: 115 edges (avg confidence: 0.8)
- Token cost: 120 input · 45 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Admin Controllers (Customers & Inventory)|Admin Controllers (Customers & Inventory)]]
- [[_COMMUNITY_Admin Controllers (Base, Orders, Products)|Admin Controllers (Base, Orders, Products)]]
- [[_COMMUNITY_Admin Controllers (Dashboard & Stats)|Admin Controllers (Dashboard & Stats)]]
- [[_COMMUNITY_Payment Flow (Jobs, Providers, AASM)|Payment Flow (Jobs, Providers, AASM)]]
- [[_COMMUNITY_Core Domain Models & Controllers|Core Domain Models & Controllers]]
- [[_COMMUNITY_Payment Simulation (Dev & Webhooks)|Payment Simulation (Dev & Webhooks)]]
- [[_COMMUNITY_API Overview & Auth Integration|API Overview & Auth Integration]]
- [[_COMMUNITY_RSpec Auth Test Helpers|RSpec Auth Test Helpers]]
- [[_COMMUNITY_JWT Middleware & App Config|JWT Middleware & App Config]]
- [[_COMMUNITY_Payment Provider Base (Strategy Pattern)|Payment Provider Base (Strategy Pattern)]]
- [[_COMMUNITY_Admin Orders Controller|Admin Orders Controller]]
- [[_COMMUNITY_Active Storage Migration|Active Storage Migration]]
- [[_COMMUNITY_Shipments Migration|Shipments Migration]]
- [[_COMMUNITY_Inventories Migration|Inventories Migration]]
- [[_COMMUNITY_Reviews Migration|Reviews Migration]]
- [[_COMMUNITY_Wishlist Items Migration|Wishlist Items Migration]]
- [[_COMMUNITY_Orders Migration|Orders Migration]]
- [[_COMMUNITY_Customer Profiles Migration|Customer Profiles Migration]]
- [[_COMMUNITY_Order Items Migration|Order Items Migration]]
- [[_COMMUNITY_Payments Migration|Payments Migration]]
- [[_COMMUNITY_Product Images Migration|Product Images Migration]]
- [[_COMMUNITY_Cart Items Migration|Cart Items Migration]]
- [[_COMMUNITY_Product Image Nullable Migration|Product Image Nullable Migration]]
- [[_COMMUNITY_Categories Migration|Categories Migration]]
- [[_COMMUNITY_Products Migration|Products Migration]]
- [[_COMMUNITY_Addresses Migration|Addresses Migration]]
- [[_COMMUNITY_OrderItem Model|OrderItem Model]]
- [[_COMMUNITY_CartItem Model|CartItem Model]]
- [[_COMMUNITY_Application Mailer|Application Mailer]]
- [[_COMMUNITY_Application Job|Application Job]]
- [[_COMMUNITY_Payment Model|Payment Model]]
- [[_COMMUNITY_CustomerProfile Model|CustomerProfile Model]]
- [[_COMMUNITY_Address Model|Address Model]]
- [[_COMMUNITY_Review Model|Review Model]]
- [[_COMMUNITY_Category Model|Category Model]]
- [[_COMMUNITY_WishlistItem Model|WishlistItem Model]]
- [[_COMMUNITY_Shipment Model|Shipment Model]]
- [[_COMMUNITY_ApplicationRecord Base|ApplicationRecord Base]]
- [[_COMMUNITY_ProductImage Model|ProductImage Model]]
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
- [[_COMMUNITY_Wishlist Item Serializer|Wishlist Item Serializer]]
- [[_COMMUNITY_Community 126|Community 126]]

## God Nodes (most connected - your core abstractions)
1. `Api::V1::BaseController` - 14 edges
2. `Order` - 13 edges
3. `Product Model` - 11 edges
4. `PaymentService` - 10 edges
5. `Product` - 9 edges
6. `BaseController` - 9 edges
7. `process_webhook!()` - 9 edges
8. `CustomerProfile Model` - 9 edges
9. `Order Model (AASM)` - 9 edges
10. `JwtAuthentication` - 8 edges

## Surprising Connections (you probably didn't know these)
- `process_webhook!()` --calls--> `Order`  [INFERRED]
  app/services/payment_service.rb → app/models/order.rb
- `process_webhook!()` --calls--> `Product`  [INFERRED]
  app/services/payment_service.rb → app/models/product.rb
- `process_webhook!()` --calls--> `Inventory`  [INFERRED]
  app/services/payment_service.rb → app/models/inventory.rb
- `OrderItem Model` --references--> `Product Model`  [EXTRACTED]
  craftit-api/docs/superpowers/plans/2026-03-22-module-2b-data-model-commerce.md → craftit-api/docs/superpowers/plans/2026-03-22-module-2a-data-model-core.md
- `Products API` --references--> `ProductsController`  [EXTRACTED]
  craftit-api/docs/api/v1/products.md → craftit-api/docs/superpowers/plans/2026-03-22-module-3-public-api.md

## Hyperedges (group relationships)
- **Payment Flow Core Participants** — payment_service, simulated_payment_provider, auto_approve_payment_job, payment_model, order_model [INFERRED 0.90]
- **Order Checkout Flow Participants** — orders_controller, order_service, inventory_service, cart_item_model, inventory_model [EXTRACTED 1.00]
- **Core Domain Data Models** — customer_profile_model, product_model, category_model, order_model, inventory_model [INFERRED 0.85]

## Communities

### Community 0 - "Admin Controllers (Customers & Inventory)"
Cohesion: 0.07
Nodes (10): CustomersController, Order, AddressesController, CartController, CategoriesController, HealthController, OrdersController, ProductsController (+2 more)

### Community 1 - "Admin Controllers (Base, Orders, Products)"
Cohesion: 0.07
Nodes (7): BaseController, ProductsController, ApplicationController, BaseController, PaymentsController, ReviewsController, ShipmentsController

### Community 2 - "Admin Controllers (Dashboard & Stats)"
Cohesion: 0.07
Nodes (9): DashboardController, InventoryController, ReservationTimeoutJob, Inventory, Product, InsufficientStockError, InventoryService, EmptyCartError (+1 more)

### Community 3 - "Payment Flow (Jobs, Providers, AASM)"
Cohesion: 0.11
Nodes (30): AASM State Machine Gem, Admin::OrdersController, AutoApprovePaymentJob, BaseProvider (Payment Interface), Dev::SimulatedPaymentsController, Inventory Reservation Flow, InventoryService, JSONAPI Serializer (+22 more)

### Community 4 - "Core Domain Models & Controllers"
Cohesion: 0.11
Nodes (30): Address Model, AddressesController, Admin::BaseController, Admin::CustomersController, Admin::DashboardController, Admin Email Authorization, Admin::InventoryController, Admin::ProductsController (+22 more)

### Community 5 - "Payment Simulation (Dev & Webhooks)"
Cohesion: 0.1
Nodes (7): SimulatedPaymentsController, AutoApprovePaymentJob, SimulatedProvider, create_payment!(), PaymentService, process_webhook!(), WebhooksController

### Community 6 - "API Overview & Auth Integration"
Cohesion: 0.16
Nodes (15): Active Storage, API v1 Overview, Authentication API, Better Auth (Next.js Frontend Auth), CORS Configuration (rack-cors), CraftIt API, Docker Compose (PostgreSQL + Adminer), JWKS Endpoint (+7 more)

### Community 7 - "RSpec Auth Test Helpers"
Cohesion: 0.25
Nodes (5): auth_headers(), authenticated_delete(), authenticated_get(), authenticated_patch(), authenticated_post()

### Community 8 - "JWT Middleware & App Config"
Cohesion: 0.24
Nodes (2): Application, JwtAuthentication

### Community 9 - "Payment Provider Base (Strategy Pattern)"
Cohesion: 0.33
Nodes (3): BaseProvider, NotImplementedError, PaymentError

### Community 11 - "Admin Orders Controller"
Cohesion: 0.5
Nodes (1): OrdersController

### Community 12 - "Active Storage Migration"
Cohesion: 0.5
Nodes (1): CreateActiveStorageTables

### Community 13 - "Shipments Migration"
Cohesion: 0.67
Nodes (1): CreateShipments

### Community 14 - "Inventories Migration"
Cohesion: 0.67
Nodes (1): CreateInventories

### Community 15 - "Reviews Migration"
Cohesion: 0.67
Nodes (1): CreateReviews

### Community 16 - "Wishlist Items Migration"
Cohesion: 0.67
Nodes (1): CreateWishlistItems

### Community 17 - "Orders Migration"
Cohesion: 0.67
Nodes (1): CreateOrders

### Community 18 - "Customer Profiles Migration"
Cohesion: 0.67
Nodes (1): CreateCustomerProfiles

### Community 19 - "Order Items Migration"
Cohesion: 0.67
Nodes (1): CreateOrderItems

### Community 20 - "Payments Migration"
Cohesion: 0.67
Nodes (1): CreatePayments

### Community 21 - "Product Images Migration"
Cohesion: 0.67
Nodes (1): CreateProductImages

### Community 22 - "Cart Items Migration"
Cohesion: 0.67
Nodes (1): CreateCartItems

### Community 23 - "Product Image Nullable Migration"
Cohesion: 0.67
Nodes (1): AllowNullProductImageUrlWhenFileAttached

### Community 24 - "Categories Migration"
Cohesion: 0.67
Nodes (1): CreateCategories

### Community 25 - "Products Migration"
Cohesion: 0.67
Nodes (1): CreateProducts

### Community 26 - "Addresses Migration"
Cohesion: 0.67
Nodes (1): CreateAddresses

### Community 27 - "OrderItem Model"
Cohesion: 0.67
Nodes (1): OrderItem

### Community 28 - "CartItem Model"
Cohesion: 0.67
Nodes (1): CartItem

### Community 29 - "Application Mailer"
Cohesion: 1.0
Nodes (1): ApplicationMailer

### Community 30 - "Application Job"
Cohesion: 1.0
Nodes (1): ApplicationJob

### Community 31 - "Payment Model"
Cohesion: 1.0
Nodes (1): Payment

### Community 32 - "CustomerProfile Model"
Cohesion: 1.0
Nodes (1): CustomerProfile

### Community 33 - "Address Model"
Cohesion: 1.0
Nodes (1): Address

### Community 34 - "Review Model"
Cohesion: 1.0
Nodes (1): Review

### Community 35 - "Category Model"
Cohesion: 1.0
Nodes (1): Category

### Community 36 - "WishlistItem Model"
Cohesion: 1.0
Nodes (1): WishlistItem

### Community 37 - "Shipment Model"
Cohesion: 1.0
Nodes (1): Shipment

### Community 38 - "ApplicationRecord Base"
Cohesion: 1.0
Nodes (1): ApplicationRecord

### Community 39 - "ProductImage Model"
Cohesion: 1.0
Nodes (1): ProductImage

### Community 40 - "Review Serializer"
Cohesion: 1.0
Nodes (1): ReviewSerializer

### Community 41 - "Category Serializer"
Cohesion: 1.0
Nodes (1): CategorySerializer

### Community 42 - "Order Detail Serializer"
Cohesion: 1.0
Nodes (1): OrderDetailSerializer

### Community 43 - "Profile Serializer"
Cohesion: 1.0
Nodes (1): ProfileSerializer

### Community 44 - "Shipment Serializer"
Cohesion: 1.0
Nodes (1): ShipmentSerializer

### Community 45 - "Order Serializer"
Cohesion: 1.0
Nodes (1): OrderSerializer

### Community 46 - "Product Detail Serializer"
Cohesion: 1.0
Nodes (1): ProductDetailSerializer

### Community 47 - "Order Item Serializer"
Cohesion: 1.0
Nodes (1): OrderItemSerializer

### Community 48 - "Cart Item Serializer"
Cohesion: 1.0
Nodes (1): CartItemSerializer

### Community 49 - "Address Serializer"
Cohesion: 1.0
Nodes (1): AddressSerializer

### Community 50 - "Product Serializer"
Cohesion: 1.0
Nodes (1): ProductSerializer

### Community 51 - "Wishlist Item Serializer"
Cohesion: 1.0
Nodes (1): WishlistItemSerializer

### Community 126 - "Community 126"
Cohesion: 1.0
Nodes (1): 1x1 PNG Test Fixture Image

## Knowledge Gaps
- **41 isolated node(s):** `ApplicationMailer`, `ApplicationJob`, `Payment`, `CustomerProfile`, `Address` (+36 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `JWT Middleware & App Config`** (11 nodes): `jwt_authentication.rb`, `Application`, `application.rb`, `JwtAuthentication`, `.call()`, `.decode_token()`, `.extract_token()`, `.fetch_jwks()`, `.initialize()`, `.jwks_cache_expired?()`, `.jwt_config()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Admin Orders Controller`** (5 nodes): `OrdersController`, `.shipment_params()`, `.status()`, `.status_event()`, `orders_controller.rb`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Active Storage Migration`** (4 nodes): `20260322212235_create_active_storage_tables.active_storage.rb`, `CreateActiveStorageTables`, `.change()`, `.primary_and_foreign_key_types()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Shipments Migration`** (3 nodes): `20260322200008_create_shipments.rb`, `CreateShipments`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Inventories Migration`** (3 nodes): `20260322192949_create_inventories.rb`, `CreateInventories`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Reviews Migration`** (3 nodes): `20260322200004_create_reviews.rb`, `CreateReviews`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Wishlist Items Migration`** (3 nodes): `20260322200003_create_wishlist_items.rb`, `CreateWishlistItems`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Orders Migration`** (3 nodes): `20260322200005_create_orders.rb`, `CreateOrders`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Customer Profiles Migration`** (3 nodes): `20260322192533_create_customer_profiles.rb`, `CreateCustomerProfiles`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Order Items Migration`** (3 nodes): `20260322200006_create_order_items.rb`, `CreateOrderItems`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Payments Migration`** (3 nodes): `20260322200007_create_payments.rb`, `CreatePayments`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Product Images Migration`** (3 nodes): `20260322192948_create_product_images.rb`, `CreateProductImages`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Cart Items Migration`** (3 nodes): `20260322200002_create_cart_items.rb`, `CreateCartItems`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Product Image Nullable Migration`** (3 nodes): `20260322212454_allow_null_product_image_url_when_file_attached.rb`, `AllowNullProductImageUrlWhenFileAttached`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Categories Migration`** (3 nodes): `20260322192610_create_categories.rb`, `CreateCategories`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Products Migration`** (3 nodes): `20260322192858_create_products.rb`, `CreateProducts`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Addresses Migration`** (3 nodes): `20260322200001_create_addresses.rb`, `CreateAddresses`, `.change()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `OrderItem Model`** (3 nodes): `order_item.rb`, `OrderItem`, `.subtotal()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `CartItem Model`** (3 nodes): `cart_item.rb`, `CartItem`, `.subtotal()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Application Mailer`** (2 nodes): `application_mailer.rb`, `ApplicationMailer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Application Job`** (2 nodes): `application_job.rb`, `ApplicationJob`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Payment Model`** (2 nodes): `payment.rb`, `Payment`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `CustomerProfile Model`** (2 nodes): `customer_profile.rb`, `CustomerProfile`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Address Model`** (2 nodes): `address.rb`, `Address`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Review Model`** (2 nodes): `review.rb`, `Review`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Category Model`** (2 nodes): `category.rb`, `Category`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `WishlistItem Model`** (2 nodes): `wishlist_item.rb`, `WishlistItem`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Shipment Model`** (2 nodes): `shipment.rb`, `Shipment`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `ApplicationRecord Base`** (2 nodes): `application_record.rb`, `ApplicationRecord`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `ProductImage Model`** (2 nodes): `product_image.rb`, `ProductImage`
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
- **Thin community `Wishlist Item Serializer`** (2 nodes): `wishlist_item_serializer.rb`, `WishlistItemSerializer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 126`** (1 nodes): `1x1 PNG Test Fixture Image`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `process_webhook!()` connect `Payment Simulation (Dev & Webhooks)` to `Admin Controllers (Customers & Inventory)`, `Admin Controllers (Dashboard & Stats)`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Why does `Order` connect `Admin Controllers (Customers & Inventory)` to `Payment Simulation (Dev & Webhooks)`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **Why does `Api::V1::BaseController` connect `Core Domain Models & Controllers` to `Payment Flow (Jobs, Providers, AASM)`, `API Overview & Auth Integration`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Are the 12 inferred relationships involving `Order` (e.g. with `.index()` and `.index()`) actually correct?**
  _`Order` has 12 INFERRED edges - model-reasoned connections that need verification._
- **Are the 5 inferred relationships involving `Product` (e.g. with `.perform()` and `.inventory_json()`) actually correct?**
  _`Product` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `ApplicationMailer`, `ApplicationJob`, `Payment` to the rest of the system?**
  _41 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Admin Controllers (Customers & Inventory)` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._