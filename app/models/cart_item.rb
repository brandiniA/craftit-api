# <rails-lens:schema:begin>
# table = "cart_items"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "customer_profile_id", type = "integer", null = false },
#   { name = "product_id", type = "integer", null = false },
#   { name = "quantity", type = "integer", null = false, default = 1 },
#   { name = "updated_at", type = "datetime", null = false }
# ]
#
# indexes = [
#   { name = "index_cart_items_on_customer_profile_id", columns = ["customer_profile_id"] },
#   { name = "index_cart_items_on_product_id", columns = ["product_id"] }
# ]
#
# foreign_keys = [
#   { column = "product_id", references_table = "products", references_column = "id", name = "fk_rails_681a180e84" },
#   { column = "customer_profile_id", references_table = "customer_profiles", references_column = "id", name = "fk_rails_c91ece3745" }
# ]
# <rails-lens:schema:end>
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
