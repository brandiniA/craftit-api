# <rails-lens:schema:begin>
# table = "categories"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "description", type = "text" },
#   { name = "image_url", type = "string" },
#   { name = "name", type = "string", null = false },
#   { name = "parent_category_id", type = "integer" },
#   { name = "position", type = "integer", default = 0 },
#   { name = "slug", type = "string", null = false },
#   { name = "updated_at", type = "datetime", null = false }
# ]
#
# indexes = [
#   { name = "index_categories_on_parent_category_id", columns = ["parent_category_id"] },
#   { name = "index_categories_on_slug", columns = ["slug"], unique = true }
# ]
#
# foreign_keys = [
#   { column = "parent_category_id", references_table = "categories", references_column = "id", name = "fk_rails_b7f1bb9825" }
# ]
#
# [callbacks]
# before_validation = [{ method = "set_slug" }]
# after_validation = [{ method = "unset_slug_if_invalid" }]
# before_save = [{ method = "set_slug" }]
#
# notes = ["parent_category:INVERSE_OF", "subcategories:N_PLUS_ONE", "products:N_PLUS_ONE", "description:NOT_NULL", "image_url:NOT_NULL", "position:NOT_NULL", "image_url:LIMIT", "name:LIMIT", "slug:LIMIT", "description:STORAGE"]
# <rails-lens:schema:end>
# == Schema Information
#
# Table name: categories
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  description         :text
#  image_url           :string
#  name                :string           not null
#  parent_category_id  :bigint
#  position            :integer          default(0)
#  slug                :string           not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_categories_on_parent_category_id  (parent_category_id)
#  index_categories_on_slug                  (slug) UNIQUE
#

class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :parent_category, class_name: "Category", optional: true
  has_many :subcategories, class_name: "Category", foreign_key: :parent_category_id,
    dependent: :nullify, inverse_of: :parent_category

  has_many :products, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :top_level, -> { where(parent_category_id: nil) }
  scope :ordered, -> { order(:position, :name) }
end
