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

require "rails_helper"

RSpec.describe Product, type: :model do
  describe "validations" do
    subject { build(:product) }

    it { is_expected.to be_valid }

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires price" do
      subject.price = nil
      expect(subject).not_to be_valid
    end

    it "requires price to be positive" do
      subject.price = -1
      expect(subject).not_to be_valid
    end

    it "requires sku" do
      subject.sku = nil
      expect(subject).not_to be_valid
    end

    it "requires unique sku" do
      create(:product, sku: "SKU-001")
      subject.sku = "SKU-001"
      expect(subject).not_to be_valid
    end

    it "requires unique slug" do
      create(:product, name: "Dragon Ball Figure", slug: "dragon-ball-figure")
      subject.slug = "dragon-ball-figure"
      expect(subject).not_to be_valid
    end

    it "allows compare_at_price to be nil" do
      subject.compare_at_price = nil
      expect(subject).to be_valid
    end

    it "requires compare_at_price to be positive when present" do
      subject.compare_at_price = -5
      expect(subject).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a category" do
      category = create(:category)
      product = create(:product, category: category)
      expect(product.category).to eq(category)
    end

    it "has many images" do
      product = create(:product)
      image = create(:product_image, product: product)
      expect(product.images).to include(image)
    end

    it "has one inventory" do
      product = create(:product)
      inventory = create(:inventory, product: product)
      expect(product.inventory).to eq(inventory)
    end
  end

  describe "slugs" do
    it "generates slug from name" do
      product = create(:product, name: "Naruto Shippuden Figure")
      expect(product.slug).to eq("naruto-shippuden-figure")
    end
  end

  describe "scopes" do
    it ".active returns only active products" do
      active = create(:product, is_active: true)
      create(:product, is_active: false)
      expect(described_class.active).to contain_exactly(active)
    end

    it ".featured returns only featured products" do
      featured = create(:product, is_featured: true)
      create(:product, is_featured: false)
      expect(described_class.featured).to contain_exactly(featured)
    end
  end
end
