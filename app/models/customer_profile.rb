# <rails-lens:schema:begin>
# table = "customer_profiles"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "auth_user_id", type = "string", null = false },
#   { name = "birth_date", type = "date" },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "phone", type = "string" },
#   { name = "updated_at", type = "datetime", null = false }
# ]
#
# indexes = [
#   { name = "index_customer_profiles_on_auth_user_id", columns = ["auth_user_id"], unique = true }
# ]
#
# notes = ["addresses:N_PLUS_ONE", "cart_items:N_PLUS_ONE", "wishlist_items:N_PLUS_ONE", "reviews:N_PLUS_ONE", "orders:N_PLUS_ONE", "phone:NOT_NULL", "auth_user_id:LIMIT", "phone:LIMIT"]
# <rails-lens:schema:end>
# == Schema Information
#
# Table name: customer_profiles
#
#  id           :integer          not null, primary key
#  auth_user_id :string           not null
#  phone        :string
#  birth_date   :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_customer_profiles_on_auth_user_id  (auth_user_id) UNIQUE
#

class CustomerProfile < ApplicationRecord
  validates :auth_user_id, presence: true, uniqueness: true

  has_many :addresses, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
end
