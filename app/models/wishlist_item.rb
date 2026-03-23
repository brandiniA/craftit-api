# <rails-lens:schema:begin>
# table = "wishlist_items"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "customer_profile_id", type = "integer", null = false },
#   { name = "product_id", type = "integer", null = false },
#   { name = "updated_at", type = "datetime", null = false }
# ]
#
# indexes = [
#   { name = "index_wishlist_items_on_customer_profile_id", columns = ["customer_profile_id"] },
#   { name = "index_wishlist_items_on_customer_profile_id_and_product_id", columns = ["customer_profile_id", "product_id"], unique = true },
#   { name = "index_wishlist_items_on_product_id", columns = ["product_id"] }
# ]
#
# foreign_keys = [
#   { column = "customer_profile_id", references_table = "customer_profiles", references_column = "id", name = "fk_rails_238fbebe4c" },
#   { column = "product_id", references_table = "products", references_column = "id", name = "fk_rails_d31985edcf" }
# ]
# <rails-lens:schema:end>
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

class WishlistItem < ApplicationRecord
  belongs_to :customer_profile
  belongs_to :product

  validates :product_id, uniqueness: { scope: :customer_profile_id }
end
