# <rails-lens:schema:begin>
# table = "product_images"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "alt_text", type = "string" },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "position", type = "integer", default = 0 },
#   { name = "product_id", type = "integer", null = false },
#   { name = "updated_at", type = "datetime", null = false },
#   { name = "url", type = "string" }
# ]
#
# indexes = [
#   { name = "index_product_images_on_product_id", columns = ["product_id"] }
# ]
#
# foreign_keys = [
#   { column = "product_id", references_table = "products", references_column = "id", name = "fk_rails_1c991d3be6" }
# ]
#
# [polymorphic]
# targets = [{ name = "file_attachment", as = "record" }]
#
# [callbacks]
# after_save = [{ method = "proc" }]
# after_commit = [{ method = "proc" }]
#
# notes = ["alt_text:NOT_NULL", "position:NOT_NULL", "url:NOT_NULL", "alt_text:LIMIT", "url:LIMIT"]
# <rails-lens:schema:end>
# == Schema Information
#
# Table name: product_images
#
#  id         :bigint           not null, primary key
#  alt_text   :string
#  created_at :datetime         not null
#  position   :integer          default(0)
#  product_id :bigint           not null
#  updated_at :datetime         not null
#  url        :string
#
# Indexes
#
#  index_product_images_on_product_id  (product_id)
#

class ProductImage < ApplicationRecord
  belongs_to :product

  has_one_attached :file

  validates :url, presence: true, unless: -> { file.attached? }

  scope :ordered, -> { order(:position) }
end
