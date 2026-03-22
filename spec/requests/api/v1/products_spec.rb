require "rails_helper"

RSpec.describe "Api::V1::Products", type: :request do
  describe "GET /api/v1/products" do
    it "returns paginated active products" do
      create_list(:product, 3, :with_inventory, is_active: true)
      create(:product, is_active: false)

      get "/api/v1/products"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
      expect(json_response).to have_key(:meta)
      expect(json_response[:meta][:total_count]).to eq(3)
    end

    it "filters by category slug" do
      category = create(:category, slug: "anime")
      create(:product, :with_inventory, category: category)
      create(:product, :with_inventory)

      get "/api/v1/products", params: { category: "anime" }

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end

    it "filters featured products" do
      create(:product, :with_inventory, is_featured: true)
      create(:product, :with_inventory, is_featured: false)

      get "/api/v1/products", params: { featured: "true" }

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end
  end

  describe "GET /api/v1/products/:slug" do
    it "returns product detail by slug" do
      product = create(:product, :with_inventory, name: "Dragon Ball Figure")
      create(:product_image, product: product)

      get "/api/v1/products/#{product.slug}"

      expect(response).to have_http_status(:ok)
      data = json_data[:attributes]
      expect(data[:name]).to eq("Dragon Ball Figure")
      expect(data[:slug]).to eq("dragon-ball-figure")
      expect(data).to have_key(:images)
      expect(data).to have_key(:available_stock)
    end

    it "returns 404 for non-existent slug" do
      get "/api/v1/products/nonexistent"

      expect(response).to have_http_status(:not_found)
      expect(json_error[:code]).to eq("not_found")
    end
  end

  describe "GET /api/v1/products/search" do
    it "searches products by name" do
      create(:product, :with_inventory, name: "Dragon Ball Figure")
      create(:product, :with_inventory, name: "Naruto Figure")

      get "/api/v1/products/search", params: { q: "dragon" }

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end

    it "returns empty results for no match" do
      get "/api/v1/products/search", params: { q: "nonexistent" }

      expect(response).to have_http_status(:ok)
      expect(json_data).to be_empty
    end
  end
end
