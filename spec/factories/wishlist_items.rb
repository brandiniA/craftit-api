# == Schema Information
#
# Table name: wishlist_items
#
#  id                  :integer          not null, primary key
#  customer_profile_id :integer          not null
#  product_id          :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_wishlist_items_on_customer_profile_id                 (customer_profile_id)
#  index_wishlist_items_on_customer_profile_id_and_product_id  (customer_profile_id,product_id) UNIQUE
#  index_wishlist_items_on_product_id                          (product_id)
#

FactoryBot.define do
  factory :wishlist_item do
    association :customer_profile
    association :product
  end
end
