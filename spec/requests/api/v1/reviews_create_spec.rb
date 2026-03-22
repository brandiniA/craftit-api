require "rails_helper"

RSpec.describe "Api::V1::Reviews (create)", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "POST /api/v1/products/:slug/reviews" do
    it "creates a review for a product" do
      product = create(:product)

      authenticated_post "/api/v1/products/#{product.slug}/reviews",
        customer_profile: profile,
        params: { rating: 5, title: "Amazing!", body: "Love this figure" }

      expect(response).to have_http_status(:created)
      expect(product.reviews.count).to eq(1)
    end

    it "returns 401 without authentication" do
      product = create(:product)

      post "/api/v1/products/#{product.slug}/reviews",
        params: { rating: 5, title: "Test" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 422 for invalid rating" do
      product = create(:product)

      authenticated_post "/api/v1/products/#{product.slug}/reviews",
        customer_profile: profile,
        params: { rating: 6, title: "Bad rating" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
