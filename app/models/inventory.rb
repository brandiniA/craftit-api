# == Schema Information
#
# Table name: inventories
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  low_stock_threshold :integer          default(5), not null
#  product_id          :bigint           not null
#  reserved_stock      :integer          default(0), not null
#  stock               :integer          default(0), not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_inventories_on_product_id  (product_id) UNIQUE
#

class Inventory < ApplicationRecord
  belongs_to :product

  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_stock, numericality: { greater_than_or_equal_to: 0 }
  validates :low_stock_threshold, numericality: { greater_than_or_equal_to: 0 }

  scope :low_stock, -> { where("stock - reserved_stock <= low_stock_threshold") }

  def available_stock
    stock - reserved_stock
  end

  def in_stock?
    available_stock > 0
  end

  def low_stock?
    available_stock <= low_stock_threshold
  end

  def sufficient_stock?(quantity)
    available_stock >= quantity
  end
end
