class ProductDetailSerializer
  include JSONAPI::Serializer

  attributes :name, :slug, :description, :price, :compare_at_price,
    :sku, :is_active, :is_featured, :created_at

  attribute :category do |product|
    if product.category
      { id: product.category.id, name: product.category.name, slug: product.category.slug }
    end
  end

  attribute :images do |product|
    product.images.ordered.map do |img|
      { id: img.id, url: img.url, alt_text: img.alt_text, position: img.position }
    end
  end

  attribute :in_stock do |product|
    product.in_stock?
  end

  attribute :available_stock do |product|
    product.available_stock
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
