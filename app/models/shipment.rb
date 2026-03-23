# <rails-lens:schema:begin>
# table = "shipments"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "carrier", type = "string" },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "estimated_delivery", type = "date" },
#   { name = "order_id", type = "integer", null = false },
#   { name = "status", type = "integer", null = false, default = 0 },
#   { name = "tracking_number", type = "string" },
#   { name = "tracking_url", type = "string" },
#   { name = "updated_at", type = "datetime", null = false }
# ]
#
# indexes = [
#   { name = "index_shipments_on_order_id", columns = ["order_id"] }
# ]
#
# foreign_keys = [
#   { column = "order_id", references_table = "orders", references_column = "id", name = "fk_rails_9892d6a938" }
# ]
#
# [enums]
# status = { preparing = 0, shipped = 1, in_transit = 2, delivered = 3 }
#
# [callbacks]
# after_initialize = [{ method = "aasm_ensure_initial_state" }]
#
# notes = ["carrier:NOT_NULL", "estimated_delivery:NOT_NULL", "tracking_number:NOT_NULL", "tracking_url:NOT_NULL", "carrier:LIMIT", "tracking_number:LIMIT", "tracking_url:LIMIT", "status:INDEX"]
# <rails-lens:schema:end>
# == Schema Information
#
# Table name: shipments
#
#  id                  :bigint           not null, primary key
#  order_id            :bigint           not null
#  carrier             :string
#  tracking_number     :string
#  tracking_url        :string
#  status              :integer          default("preparing"), not null
#  estimated_delivery  :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_shipments_on_order_id  (order_id)
#

class Shipment < ApplicationRecord
  include AASM

  belongs_to :order

  enum :status, {
    preparing: 0,
    shipped: 1,
    in_transit: 2,
    delivered: 3
  }

  aasm column: :status, enum: true do
    state :preparing, initial: true
    state :shipped
    state :in_transit
    state :delivered

    event :ship do
      transitions from: :preparing, to: :shipped
    end

    event :in_transit do
      transitions from: :shipped, to: :in_transit
    end

    event :deliver do
      transitions from: [ :shipped, :in_transit ], to: :delivered
    end
  end
end
