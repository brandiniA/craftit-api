class CategorySerializer
  include JSONAPI::Serializer

  attributes :name, :slug, :description, :image_url, :position

  attribute :parent_category do |category|
    if category.parent_category
      { id: category.parent_category.id, name: category.parent_category.name, slug: category.parent_category.slug }
    end
  end

  attribute :subcategories do |category|
    category.subcategories.ordered.map do |sub|
      { id: sub.id, name: sub.name, slug: sub.slug, image_url: sub.image_url }
    end
  end

  attribute :product_count do |category|
    category.products.active.count
  end
end
