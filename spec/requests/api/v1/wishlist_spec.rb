require "rails_helper"

RSpec.describe "Api::V1::Wishlist", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "GET /api/v1/wishlist" do
    it "returns 401 without authentication" do
      get "/api/v1/wishlist"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns wishlist items" do
      product = create(:product, :with_inventory)
      create(:wishlist_item, customer_profile: profile, product: product)

      authenticated_get "/api/v1/wishlist", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end
  end

  describe "POST /api/v1/wishlist/items" do
    it "adds product to wishlist" do
      product = create(:product)

      authenticated_post "/api/v1/wishlist/items",
        customer_profile: profile,
        params: { product_id: product.id }

      expect(response).to have_http_status(:created)
      expect(profile.wishlist_items.count).to eq(1)
    end

    it "returns 409 if product already in wishlist" do
      product = create(:product)
      create(:wishlist_item, customer_profile: profile, product: product)

      authenticated_post "/api/v1/wishlist/items",
        customer_profile: profile,
        params: { product_id: product.id }

      expect(response).to have_http_status(:conflict)
    end
  end

  describe "DELETE /api/v1/wishlist/items/:id" do
    it "removes product from wishlist" do
      item = create(:wishlist_item, customer_profile: profile)

      authenticated_delete "/api/v1/wishlist/items/#{item.id}", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(profile.wishlist_items.count).to eq(0)
    end
  end
end
