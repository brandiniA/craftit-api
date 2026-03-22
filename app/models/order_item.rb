# == Schema Information
#
# Table name: order_items
#
#  id                    :integer          not null, primary key
#  order_id              :integer          not null
#  product_id            :integer          not null
#  product_name_snapshot :string           not null
#  price_snapshot        :decimal(10, 2)   not null
#  quantity              :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_order_items_on_order_id    (order_id)
#  index_order_items_on_product_id  (product_id)
#

class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :product_name_snapshot, presence: true
  validates :price_snapshot, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  def subtotal
    price_snapshot * quantity
  end
end
