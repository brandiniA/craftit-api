# <rails-lens:schema:begin>
# table = "products"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "category_id", type = "integer" },
#   { name = "compare_at_price", type = "decimal" },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "description", type = "text" },
#   { name = "is_active", type = "boolean", null = false, default = true },
#   { name = "is_featured", type = "boolean", null = false },
#   { name = "name", type = "string", null = false },
#   { name = "price", type = "decimal", null = false },
#   { name = "sku", type = "string", null = false },
#   { name = "slug", type = "string", null = false },
#   { name = "updated_at", type = "datetime", null = false }
# ]
#
# indexes = [
#   { name = "index_products_on_category_id", columns = ["category_id"] },
#   { name = "index_products_on_category_id_and_is_active", columns = ["category_id", "is_active"] },
#   { name = "index_products_on_sku", columns = ["sku"], unique = true },
#   { name = "index_products_on_slug", columns = ["slug"], unique = true }
# ]
#
# foreign_keys = [
#   { column = "category_id", references_table = "categories", references_column = "id", name = "fk_rails_fb915499a4" }
# ]
#
# [callbacks]
# before_validation = [{ method = "set_slug" }]
# after_validation = [{ method = "unset_slug_if_invalid" }]
# before_save = [{ method = "set_slug" }]
#
# notes = ["index_products_on_category_id:REDUND_IDX", "images:INVERSE_OF", "images:N_PLUS_ONE", "cart_items:N_PLUS_ONE", "wishlist_items:N_PLUS_ONE", "reviews:N_PLUS_ONE", "order_items:N_PLUS_ONE", "compare_at_price:NOT_NULL", "description:NOT_NULL", "name:LIMIT", "sku:LIMIT", "slug:LIMIT", "description:STORAGE"]
# <rails-lens:schema:end>
# == Schema Information
#
# Table name: products
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  slug             :string           not null
#  description      :text
#  price            :decimal(10, 2)   not null
#  compare_at_price :decimal(10, 2)
#  sku              :string           not null
#  category_id      :integer
#  is_active        :boolean          default(TRUE), not null
#  is_featured      :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_products_on_category_id                (category_id)
#  index_products_on_category_id_and_is_active  (category_id,is_active)
#  index_products_on_sku                        (sku) UNIQUE
#  index_products_on_slug                       (slug) UNIQUE
#

class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :category, optional: true
  has_many :images, class_name: "ProductImage", dependent: :destroy
  has_one :inventory, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :compare_at_price, numericality: { greater_than: 0 }, allow_nil: true

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :featured, -> { where(is_featured: true) }

  def available_stock
    inventory&.available_stock || 0
  end

  def in_stock?
    available_stock > 0
  end

  def on_sale?
    compare_at_price.present? && compare_at_price > price
  end
end
