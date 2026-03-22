# == Schema Information
#
# Table name: cart_items
#
#  id                  :bigint           not null, primary key
#  customer_profile_id :bigint           not null
#  product_id          :bigint           not null
#  quantity            :integer          default(1), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_cart_items_on_customer_profile_id  (customer_profile_id)
#  index_cart_items_on_product_id           (product_id)
#

class CartItem < ApplicationRecord
  belongs_to :customer_profile
  belongs_to :product

  validates :quantity, presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  def subtotal
    product.price * quantity
  end
end
