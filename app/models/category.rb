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
