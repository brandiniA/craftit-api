# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_22_212454) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "graphql.pg_graphql"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "city", null: false
    t.string "country", default: "MX", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_profile_id", null: false
    t.boolean "is_default", default: false, null: false
    t.string "label"
    t.string "state", null: false
    t.string "street", null: false
    t.datetime "updated_at", null: false
    t.string "zip_code", null: false
    t.index ["customer_profile_id"], name: "index_addresses_on_customer_profile_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_profile_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["customer_profile_id"], name: "index_cart_items_on_customer_profile_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name", null: false
    t.bigint "parent_category_id"
    t.integer "position", default: 0
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_category_id"], name: "index_categories_on_parent_category_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "customer_profiles", force: :cascade do |t|
    t.string "auth_user_id", null: false
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["auth_user_id"], name: "index_customer_profiles_on_auth_user_id", unique: true
  end

  create_table "inventories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "low_stock_threshold", default: 5, null: false
    t.bigint "product_id", null: false
    t.integer "reserved_stock", default: 0, null: false
    t.integer "stock", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_inventories_on_product_id", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.decimal "price_snapshot", precision: 10, scale: 2, null: false
    t.bigint "product_id", null: false
    t.string "product_name_snapshot", null: false
    t.integer "quantity", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "customer_email_snapshot"
    t.string "customer_name_snapshot"
    t.bigint "customer_profile_id", null: false
    t.string "order_number", null: false
    t.jsonb "shipping_address_snapshot", default: {}
    t.decimal "shipping_cost", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "status", default: 0, null: false
    t.decimal "subtotal", precision: 10, scale: 2, null: false
    t.decimal "tax", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "tax_rate_snapshot", precision: 5, scale: 4, default: "0.16", null: false
    t.decimal "total", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["customer_profile_id"], name: "index_orders_on_customer_profile_id"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "MXN", null: false
    t.bigint "order_id", null: false
    t.string "provider", null: false
    t.string "provider_payment_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.string "alt_text"
    t.datetime "created_at", null: false
    t.integer "position", default: 0
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "category_id"
    t.decimal "compare_at_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_active", default: true, null: false
    t.boolean "is_featured", default: false, null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "sku", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "is_active"], name: "index_products_on_category_id_and_is_active"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.bigint "customer_profile_id", null: false
    t.boolean "is_verified_purchase", default: false, null: false
    t.bigint "product_id", null: false
    t.integer "rating", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["customer_profile_id"], name: "index_reviews_on_customer_profile_id"
    t.index ["product_id"], name: "index_reviews_on_product_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.string "carrier"
    t.datetime "created_at", null: false
    t.date "estimated_delivery"
    t.bigint "order_id", null: false
    t.integer "status", default: 0, null: false
    t.string "tracking_number"
    t.string "tracking_url"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_shipments_on_order_id"
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_profile_id", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_profile_id", "product_id"], name: "index_wishlist_items_on_customer_profile_id_and_product_id", unique: true
    t.index ["customer_profile_id"], name: "index_wishlist_items_on_customer_profile_id"
    t.index ["product_id"], name: "index_wishlist_items_on_product_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "customer_profiles"
  add_foreign_key "cart_items", "customer_profiles"
  add_foreign_key "cart_items", "products"
  add_foreign_key "categories", "categories", column: "parent_category_id"
  add_foreign_key "inventories", "products"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "customer_profiles"
  add_foreign_key "payments", "orders"
  add_foreign_key "product_images", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "reviews", "customer_profiles"
  add_foreign_key "reviews", "products"
  add_foreign_key "shipments", "orders"
  add_foreign_key "wishlist_items", "customer_profiles"
  add_foreign_key "wishlist_items", "products"
end
