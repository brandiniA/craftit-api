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
#  url        :string           not null
#
# Indexes
#
#  index_product_images_on_product_id  (product_id)
#

class ProductImage < ApplicationRecord
  belongs_to :product

  validates :url, presence: true

  scope :ordered, -> { order(:position) }
end
