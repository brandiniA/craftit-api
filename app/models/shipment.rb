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
