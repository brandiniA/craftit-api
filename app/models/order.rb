# <rails-lens:schema:begin>
# table = "orders"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "customer_email_snapshot", type = "string" },
#   { name = "customer_name_snapshot", type = "string" },
#   { name = "customer_profile_id", type = "integer", null = false },
#   { name = "order_number", type = "string", null = false },
#   { name = "shipping_address_snapshot", type = "jsonb", default = "{}" },
#   { name = "shipping_cost", type = "decimal", null = false, default = 0.0 },
#   { name = "status", type = "integer", null = false, default = 0 },
#   { name = "subtotal", type = "decimal", null = false },
#   { name = "tax", type = "decimal", null = false, default = 0.0 },
#   { name = "tax_rate_snapshot", type = "decimal", null = false, default = 0.16 },
#   { name = "total", type = "decimal", null = false },
#   { name = "updated_at", type = "datetime", null = false }
# ]
#
# indexes = [
#   { name = "index_orders_on_customer_profile_id", columns = ["customer_profile_id"] },
#   { name = "index_orders_on_order_number", columns = ["order_number"], unique = true }
# ]
#
# foreign_keys = [
#   { column = "customer_profile_id", references_table = "customer_profiles", references_column = "id", name = "fk_rails_169bf452a1" }
# ]
#
# [enums]
# status = { pending = 0, paid = 1, processing = 2, shipped = 3, delivered = 4, cancelled = 5 }
#
# [callbacks]
# after_initialize = [{ method = "aasm_ensure_initial_state" }]
#
# notes = ["order_items:N_PLUS_ONE", "customer_email_snapshot:NOT_NULL", "customer_name_snapshot:NOT_NULL", "shipping_address_snapshot:NOT_NULL", "customer_email_snapshot:LIMIT", "customer_name_snapshot:LIMIT", "order_number:LIMIT", "customer_email_snapshot:INDEX", "status:INDEX"]
# <rails-lens:schema:end>
# == Schema Information
#
# Table name: orders
#
#  id                        :bigint           not null, primary key
#  customer_profile_id       :bigint           not null
#  order_number              :string           not null
#  status                    :integer          default("pending"), not null
#  subtotal                  :decimal(10, 2)   not null
#  shipping_cost             :decimal(10, 2)   default(0.0), not null
#  tax                       :decimal(10, 2)   default(0.0), not null
#  tax_rate_snapshot         :decimal(5, 4)    default(0.16), not null
#  total                     :decimal(10, 2)   not null
#  customer_name_snapshot    :string
#  customer_email_snapshot   :string
#  shipping_address_snapshot :jsonb
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_orders_on_customer_profile_id  (customer_profile_id)
#  index_orders_on_order_number         (order_number) UNIQUE
#

class Order < ApplicationRecord
  include AASM

  belongs_to :customer_profile
  has_many :order_items, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_one :shipment, dependent: :destroy

  validates :order_number, presence: true, uniqueness: true
  validates :subtotal, :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_cost, :tax, numericality: { greater_than_or_equal_to: 0 }

  enum :status, {
    pending: 0,
    paid: 1,
    processing: 2,
    shipped: 3,
    delivered: 4,
    cancelled: 5
  }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :paid
    state :processing
    state :shipped
    state :delivered
    state :cancelled

    event :pay do
      transitions from: :pending, to: :paid
    end

    event :process do
      transitions from: :paid, to: :processing
    end

    event :ship do
      transitions from: :processing, to: :shipped
    end

    event :deliver do
      transitions from: :shipped, to: :delivered
    end

    event :cancel do
      transitions from: [ :pending, :paid, :processing ], to: :cancelled
    end
  end
end
