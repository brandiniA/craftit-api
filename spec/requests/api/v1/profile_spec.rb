require "rails_helper"

RSpec.describe "Api::V1::Profile", type: :request do
  let(:profile) { create(:customer_profile, phone: "+52 55 1234 5678") }

  describe "GET /api/v1/profile" do
    it "returns 401 without authentication" do
      get "/api/v1/profile"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the current user profile" do
      authenticated_get "/api/v1/profile", customer_profile: profile

      expect(response).to have_http_status(:ok)
      expect(json_data[:attributes][:phone]).to eq("+52 55 1234 5678")
    end

    it "auto-creates profile on first request" do
      new_profile = build(:customer_profile)

      authenticated_get "/api/v1/profile", customer_profile: new_profile

      expect(response).to have_http_status(:ok)
      expect(CustomerProfile.find_by(auth_user_id: new_profile.auth_user_id)).to be_present
    end
  end

  describe "PATCH /api/v1/profile" do
    it "updates profile fields" do
      authenticated_patch "/api/v1/profile",
        customer_profile: profile,
        params: { phone: "+52 55 9876 5432", birth_date: "1990-05-15" }

      expect(response).to have_http_status(:ok)
      expect(profile.reload.phone).to eq("+52 55 9876 5432")
      expect(profile.reload.birth_date).to eq(Date.new(1990, 5, 15))
    end
  end
end
