require "rails_helper"

RSpec.describe "Api::V1::Admin::Customers", type: :request do
  before { ENV["ADMIN_EMAIL"] = "admin@craftitapp.com" }

  describe "GET /api/v1/admin/customers" do
    it "returns all customer profiles" do
      create_list(:customer_profile, 3)

      admin_get "/api/v1/admin/customers"

      expect(response).to have_http_status(:ok)
      expect(json_data.length).to eq(3)
    end
  end

  describe "GET /api/v1/admin/customers/:id" do
    it "returns a specific customer" do
      profile = create(:customer_profile)

      admin_get "/api/v1/admin/customers/#{profile.id}"

      expect(response).to have_http_status(:ok)
    end
  end
end
