# <rails-lens:schema:begin>
# table = "order_items"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "order_id", type = "integer", null = false },
#   { name = "price_snapshot", type = "decimal", null = false },
#   { name = "product_id", type = "integer", null = false },
#   { name = "product_name_snapshot", type = "string", null = false },
#   { name = "quantity", type = "integer", null = false },
#   { name = "updated_at", type = "datetime", null = false }
# ]
#
# indexes = [
#   { name = "index_order_items_on_order_id", columns = ["order_id"] },
#   { name = "index_order_items_on_product_id", columns = ["product_id"] }
# ]
#
# foreign_keys = [
#   { column = "order_id", references_table = "orders", references_column = "id", name = "fk_rails_e3cb28f071" },
#   { column = "product_id", references_table = "products", references_column = "id", name = "fk_rails_f1a29ddd47" }
# ]
#
# notes = ["product_name_snapshot:LIMIT"]
# <rails-lens:schema:end>
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
