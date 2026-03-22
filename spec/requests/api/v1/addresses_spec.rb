require "rails_helper"

RSpec.describe "Api::V1::Addresses", type: :request do
  let(:profile) { create(:customer_profile) }

  describe "GET /api/v1/addresses" do
    it "returns 401 without authentication" do
      get "/api/v1/addresses"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns user addresses" do
      create(:address, customer_profile: profile)

      authenticated_get "/api/v1/addresses", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(1)
    end

    it "does not return other users addresses" do
      other = create(:customer_profile)
      create(:address, customer_profile: other)

      authenticated_get "/api/v1/addresses", customer_profile: profile

      expect(json_data).to be_empty
    end
  end

  describe "POST /api/v1/addresses" do
    it "creates a new address" do
      authenticated_post "/api/v1/addresses",
        customer_profile: profile,
        params: {
          label: "Home",
          street: "Av. Reforma 123",
          city: "CDMX",
          state: "Ciudad de México",
          zip_code: "06600",
          country: "MX"
        }

      expect(response).to have_http_status(:created)
      expect(profile.addresses.count).to eq(1)
    end

    it "returns 422 for missing required fields" do
      authenticated_post "/api/v1/addresses",
        customer_profile: profile,
        params: { label: "Home" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/addresses/:id" do
    it "updates an address" do
      address = create(:address, customer_profile: profile, city: "Guadalajara")

      authenticated_patch "/api/v1/addresses/#{address.id}",
        customer_profile: profile,
        params: { city: "Monterrey" }

      expect(response).to have_http_status(:ok)
      expect(address.reload.city).to eq("Monterrey")
    end
  end

  describe "DELETE /api/v1/addresses/:id" do
    it "deletes an address" do
      address = create(:address, customer_profile: profile)

      authenticated_delete "/api/v1/addresses/#{address.id}", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(profile.addresses.count).to eq(0)
    end
  end
end
