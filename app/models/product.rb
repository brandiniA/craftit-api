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
