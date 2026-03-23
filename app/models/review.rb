# <rails-lens:schema:begin>
# table = "reviews"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "body", type = "text" },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "customer_profile_id", type = "integer", null = false },
#   { name = "is_verified_purchase", type = "boolean", null = false },
#   { name = "product_id", type = "integer", null = false },
#   { name = "rating", type = "integer", null = false },
#   { name = "title", type = "string" },
#   { name = "updated_at", type = "datetime", null = false }
# ]
#
# indexes = [
#   { name = "index_reviews_on_customer_profile_id", columns = ["customer_profile_id"] },
#   { name = "index_reviews_on_product_id", columns = ["product_id"] }
# ]
#
# foreign_keys = [
#   { column = "customer_profile_id", references_table = "customer_profiles", references_column = "id", name = "fk_rails_717b9e771b" },
#   { column = "product_id", references_table = "products", references_column = "id", name = "fk_rails_bedd9094d4" }
# ]
#
# notes = ["body:NOT_NULL", "title:NOT_NULL", "title:LIMIT", "body:STORAGE"]
# <rails-lens:schema:end>
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
