# <rails-lens:schema:begin>
# table = "payments"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "amount", type = "decimal", null = false },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "currency", type = "string", null = false, default = "MXN" },
#   { name = "order_id", type = "integer", null = false },
#   { name = "provider", type = "string", null = false },
#   { name = "provider_payment_id", type = "string" },
#   { name = "status", type = "integer", null = false, default = 0 },
#   { name = "updated_at", type = "datetime", null = false }
# ]
#
# indexes = [
#   { name = "index_payments_on_order_id", columns = ["order_id"] }
# ]
#
# foreign_keys = [
#   { column = "order_id", references_table = "orders", references_column = "id", name = "fk_rails_6af949464b" }
# ]
#
# [enums]
# status = { pending = 0, completed = 1, failed = 2, refunded = 3 }
#
# [callbacks]
# after_initialize = [{ method = "aasm_ensure_initial_state" }]
#
# notes = ["currency:LIMIT", "provider:LIMIT", "provider_payment_id:LIMIT", "status:INDEX"]
# <rails-lens:schema:end>
# == Schema Information
#
# Table name: payments
#
#  id                   :bigint           not null, primary key
#  order_id             :bigint           not null
#  provider             :string           not null
#  provider_payment_id  :string
#  status               :integer          default("pending"), not null
#  amount               :decimal(10, 2)   not null
#  currency             :string           default("MXN"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_payments_on_order_id  (order_id)
#

class Payment < ApplicationRecord
  include AASM

  belongs_to :order

  validates :provider, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true

  enum :status, {
    pending: 0,
    completed: 1,
    failed: 2,
    refunded: 3
  }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :completed
    state :failed
    state :refunded

    event :complete do
      transitions from: :pending, to: :completed
    end

    event :fail_payment do
      transitions from: :pending, to: :failed
    end

    event :refund do
      transitions from: :completed, to: :refunded
    end
  end
end
