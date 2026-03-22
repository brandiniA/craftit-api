# Products API

Public endpoints for browsing and searching products.

**Base Path:** `/api/v1/products`

**Authentication:** None required (public)

---

## List Products

```
GET /api/v1/products
```

Returns paginated list of active products.

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | integer | No | Page number (default: 1) |
| `items` | integer | No | Items per page (default: 20) |
| `category` | string | No | Filter by category slug |
| `featured` | boolean | No | Filter featured products (`true` / `false`) |

### Example Request

```bash
GET /api/v1/products?category=ceramics&page=1&items=10
```

### Example Response

```json
{
  "data": [
    {
      "id": "1",
      "type": "product",
      "attributes": {
        "name": "Handcrafted Ceramic Bowl",
        "slug": "handcrafted-ceramic-bowl",
        "description": "Beautiful handmade ceramic bowl...",
        "price": "450.00",
        "featured": true,
        "active": true,
        "category": {
          "id": 1,
          "name": "Ceramics",
          "slug": "ceramics"
        },
        "images": [
          {
            "id": 1,
            "url": "/rails/active_storage/blobs/...",
            "position": 1
          }
        ],
        "inventory": {
          "stock": 15,
          "in_stock": true
        },
        "average_rating": 4.5,
        "review_count": 12
      }
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total_pages": 3,
    "total_count": 28
  }
}
```

### Notes

- Only `active: true` products are returned
- Products ordered by `created_at DESC` (newest first)
- Includes eager-loaded: category, images, inventory, reviews (for ratings)

---

## Get Product Detail

```
GET /api/v1/products/:slug
```

Returns detailed product information by slug.

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `slug` | string | Yes | Product slug (FriendlyId) |

### Example Request

```bash
GET /api/v1/products/handcrafted-ceramic-bowl
```

### Example Response

```json
{
  "data": {
    "id": "1",
    "type": "product_detail",
    "attributes": {
      "name": "Handcrafted Ceramic Bowl",
      "slug": "handcrafted-ceramic-bowl",
      "description": "Beautiful handmade ceramic bowl perfect for serving...",
      "price": "450.00",
      "featured": true,
      "active": true,
      "category": {
        "id": 1,
        "name": "Ceramics",
        "slug": "ceramics"
      },
      "images": [
        {
          "id": 1,
          "url": "/rails/active_storage/blobs/redirect/...",
          "position": 1
        },
        {
          "id": 2,
          "url": "/rails/active_storage/blobs/redirect/...",
          "position": 2
        }
      ],
      "inventory": {
        "stock": 15,
        "in_stock": true
      },
      "reviews": [
        {
          "id": 1,
          "rating": 5,
          "comment": "Amazing quality!",
          "customer_name": "John Doe",
          "created_at": "2026-03-15T10:30:00Z"
        }
      ],
      "average_rating": 4.5,
      "review_count": 12
    }
  }
}
```

### Error Responses

**404 Not Found** — Product slug not found

```json
{
  "error": {
    "code": "not_found",
    "message": "Couldn't find Product"
  }
}
```

---

## Search Products

```
GET /api/v1/products/search
```

Full-text search across products with filters.

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `q` | string | No | Search term (ILIKE on product name) |
| `min_price` | decimal | No | Minimum price filter |
| `max_price` | decimal | No | Maximum price filter |
| `category` | string | No | Filter by category slug |
| `page` | integer | No | Page number (default: 1) |
| `items` | integer | No | Items per page (default: 20) |

### Example Request

```bash
GET /api/v1/products/search?q=bowl&min_price=200&max_price=600&category=ceramics
```

### Example Response

Same format as **List Products** response.

### Search Behavior

- `q` parameter uses case-insensitive ILIKE: `name ILIKE '%bowl%'`
- All filters are combinable (AND logic)
- Results ordered by `created_at DESC`
- Only active products returned

### Future Enhancements

Consider replacing ILIKE with full-text search (PostgreSQL `tsvector`, Elasticsearch, etc.) for better performance on large datasets.

---

## Implementation Notes

### FriendlyId Slugs

Products use [FriendlyId](https://github.com/norman/friendly_id) gem for SEO-friendly URLs.

**Model:** `app/models/product.rb`

```ruby
class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
end
```

**URL Pattern:** `/products/handcrafted-ceramic-bowl` (instead of `/products/123`)

### Active Storage Images

Product images use Rails Active Storage (local disk in development, S3/Supabase in production).

**Disk storage location:** `./storage/` (gitignored)

**Image URLs:** Rails redirects to signed blob URLs:
- `/rails/active_storage/blobs/redirect/:signed_id/*filename`

### Inventory Integration

`in_stock` is calculated from `Inventory` model:

```ruby
inventory.in_stock  # => true if stock > 0
```

Reserved stock (cart reservations) is **not** deducted from public `stock` display until order is confirmed.

---

## Related Endpoints

- [Reviews API](reviews.md) — Product reviews (nested under products)
- [Categories API](categories.md) — Category filtering
- [Cart API](cart.md) — Add products to cart

---

## Testing

### RSpec Request Specs

**Location:** `spec/requests/api/v1/products_spec.rb`

**Key scenarios:**
- List products with pagination
- Filter by category
- Filter featured products
- Product detail by slug
- Search with multiple filters
- 404 for invalid slug
