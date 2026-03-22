require "rails_helper"

RSpec.describe "Api::V1::Reviews", type: :request do
  describe "GET /api/v1/products/:slug/reviews" do
    it "returns paginated reviews for a product" do
      product = create(:product)
      create_list(:review, 3, product: product)

      get "/api/v1/products/#{product.slug}/reviews"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
    end

    it "returns 404 for non-existent product" do
      get "/api/v1/products/nonexistent/reviews"

      expect(response).to have_http_status(:not_found)
    end

    it "returns review summary in meta" do
      product = create(:product)
      create(:review, product: product, rating: 5)
      create(:review, product: product, rating: 3)

      get "/api/v1/products/#{product.slug}/reviews"

      expect(json_response[:meta][:average_rating]).to eq(4.0)
      expect(json_response[:meta][:total_count]).to eq(2)
    end
  end
end
