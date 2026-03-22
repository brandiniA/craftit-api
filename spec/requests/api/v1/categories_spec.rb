require "rails_helper"

RSpec.describe "Api::V1::Categories", type: :request do
  describe "GET /api/v1/categories" do
    it "returns all top-level categories" do
      create(:category)
      create(:category, :with_parent)

      get "/api/v1/categories"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to be >= 1
    end
  end

  describe "GET /api/v1/categories/:slug" do
    it "returns category with its products" do
      category = create(:category, name: "Anime Figures")
      create(:product, :with_inventory, category: category)

      get "/api/v1/categories/#{category.slug}"

      expect(response).to have_http_status(:ok)
      data = json_data
      expect(data[:category][:attributes][:name]).to eq("Anime Figures")
      expect(data[:products].length).to eq(1)
    end

    it "returns 404 for non-existent slug" do
      get "/api/v1/categories/nonexistent"

      expect(response).to have_http_status(:not_found)
    end
  end
end
