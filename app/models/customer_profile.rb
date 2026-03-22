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
