# == Schema Information
#
# Table name: products
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  slug             :string           not null
#  description      :text
#  price            :decimal(10, 2)   not null
#  compare_at_price :decimal(10, 2)
#  sku              :string           not null
#  category_id      :integer
#  is_active        :boolean          default(TRUE), not null
#  is_featured      :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_products_on_category_id                (category_id)
#  index_products_on_category_id_and_is_active  (category_id,is_active)
#  index_products_on_sku                        (sku) UNIQUE
#  index_products_on_slug                       (slug) UNIQUE
#

FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    slug { nil } # Let FriendlyId generate it
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    price { Faker::Commerce.price(range: 100..5000.0) }
    compare_at_price { nil }
    sku { "SKU-#{SecureRandom.hex(4).upcase}" }
    association :category
    is_active { true }
    is_featured { false }

    trait :inactive do
      is_active { false }
    end

    trait :featured do
      is_featured { true }
    end

    trait :on_sale do
      price { 299.99 }
      compare_at_price { 499.99 }
    end

    trait :with_inventory do
      after(:create) do |product|
        create(:inventory, product: product)
      end
    end
  end
end
