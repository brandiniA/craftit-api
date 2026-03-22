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
