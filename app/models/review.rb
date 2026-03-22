# == Schema Information
#
# Table name: reviews
#
#  id                   :integer          not null, primary key
#  customer_profile_id  :integer          not null
#  product_id           :integer          not null
#  rating               :integer          not null
#  title                :string
#  body                 :text
#  is_verified_purchase :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_reviews_on_customer_profile_id  (customer_profile_id)
#  index_reviews_on_product_id           (product_id)
#

class Review < ApplicationRecord
  belongs_to :customer_profile
  belongs_to :product

  validates :rating, presence: true,
    numericality: { only_integer: true, in: 1..5 }
end
