require "rails_helper"

RSpec.describe "Api::V1::Admin::Products", type: :request do
  before { ENV["ADMIN_EMAIL"] = "admin@craftitapp.com" }

  describe "GET /api/v1/admin/products" do
    it "returns all products (including inactive)" do
      create(:product, is_active: true)
      create(:product, is_active: false)

      admin_get "/api/v1/admin/products"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(2)
    end
  end

  describe "POST /api/v1/admin/products" do
    it "creates a product" do
      category = create(:category)

      admin_post "/api/v1/admin/products", params: {
        name: "New Figure",
        price: 599.99,
        sku: "FIG-NEW-001",
        description: "A new figure",
        category_id: category.id
      }

      expect(response).to have_http_status(:created)
      expect(Product.last.name).to eq("New Figure")
    end

    it "creates inventory alongside product" do
      admin_post "/api/v1/admin/products", params: {
        name: "New Figure",
        price: 599.99,
        sku: "FIG-NEW-002",
        initial_stock: 25
      }

      expect(response).to have_http_status(:created)
      expect(Product.last.inventory.stock).to eq(25)
    end

    it "returns 422 for invalid data" do
      admin_post "/api/v1/admin/products", params: { name: "" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/admin/products/:id" do
    it "updates a product" do
      product = create(:product, name: "Old Name")

      admin_patch "/api/v1/admin/products/#{product.id}", params: { name: "New Name" }

      expect(response).to have_http_status(:ok)
      expect(product.reload.name).to eq("New Name")
    end
  end

  describe "DELETE /api/v1/admin/products/:id" do
    it "soft deletes (deactivates) the product" do
      product = create(:product, is_active: true)

      admin_delete "/api/v1/admin/products/#{product.id}"

      expect(response).to have_http_status(:ok)
      expect(product.reload.is_active).to be false
    end
  end
end
