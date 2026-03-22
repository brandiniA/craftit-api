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

ActiveRecord::Schema[8.1].define(version: 2026_03_22_192949) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name", null: false
    t.bigint "parent_category_id"
    t.integer "position", default: 0
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index [ "parent_category_id" ], name: "index_categories_on_parent_category_id"
    t.index [ "slug" ], name: "index_categories_on_slug", unique: true
  end

  create_table "customer_profiles", force: :cascade do |t|
    t.string "auth_user_id", null: false
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index [ "auth_user_id" ], name: "index_customer_profiles_on_auth_user_id", unique: true
  end

  create_table "inventories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "low_stock_threshold", default: 5, null: false
    t.bigint "product_id", null: false
    t.integer "reserved_stock", default: 0, null: false
    t.integer "stock", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index [ "product_id" ], name: "index_inventories_on_product_id", unique: true
  end

  create_table "product_images", force: :cascade do |t|
    t.string "alt_text"
    t.datetime "created_at", null: false
    t.integer "position", default: 0
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index [ "product_id" ], name: "index_product_images_on_product_id"
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
    t.index [ "category_id", "is_active" ], name: "index_products_on_category_id_and_is_active"
    t.index [ "category_id" ], name: "index_products_on_category_id"
    t.index [ "sku" ], name: "index_products_on_sku", unique: true
    t.index [ "slug" ], name: "index_products_on_slug", unique: true
  end

  add_foreign_key "categories", "categories", column: "parent_category_id"
  add_foreign_key "inventories", "products"
  add_foreign_key "product_images", "products"
  add_foreign_key "products", "categories"
end
