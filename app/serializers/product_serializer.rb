class ProductSerializer
  include JSONAPI::Serializer

  attributes :name, :slug, :price, :compare_at_price, :is_active, :is_featured

  attribute :category_name do |product|
    product.category&.name
  end

  attribute :primary_image_url do |product|
    product.images.ordered.first&.url
  end

  attribute :in_stock do |product|
    product.in_stock?
  end

  attribute :on_sale do |product|
    product.on_sale?
  end

  attribute :average_rating do |product|
    product.reviews.average(:rating)&.round(1)
  end

  attribute :review_count do |product|
    product.reviews.count
  end
end
