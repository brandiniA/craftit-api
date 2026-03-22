require "rails_helper"

RSpec.describe "Api::V1::Admin::Inventory", type: :request do
  before { ENV["ADMIN_EMAIL"] = "admin@craftitapp.com" }

  describe "GET /api/v1/admin/inventory" do
    it "returns all inventory" do
      create_list(:product, 3, :with_inventory)

      admin_get "/api/v1/admin/inventory"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
    end
  end

  describe "GET /api/v1/admin/inventory/low-stock" do
    it "returns only low stock items" do
      p1 = create(:product)
      p2 = create(:product)
      create(:inventory, product: p1, stock: 2, low_stock_threshold: 5)
      create(:inventory, product: p2, stock: 50, low_stock_threshold: 5)

      admin_get "/api/v1/admin/inventory/low-stock"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end
  end

  describe "PATCH /api/v1/admin/inventory/:product_id" do
    it "updates stock for a product" do
      product = create(:product)
      inventory = create(:inventory, product: product, stock: 10)

      admin_patch "/api/v1/admin/inventory/#{product.id}",
        params: { stock: 50, low_stock_threshold: 10 }

      expect(response).to have_http_status(:ok)
      expect(inventory.reload.stock).to eq(50)
      expect(inventory.reload.low_stock_threshold).to eq(10)
    end
  end
end
