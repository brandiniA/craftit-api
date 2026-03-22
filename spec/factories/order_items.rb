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

FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    product_name_snapshot { Faker::Commerce.product_name }
    price_snapshot { Faker::Commerce.price(range: 100..2000.0) }
    quantity { Faker::Number.between(from: 1, to: 5) }
  end
end
