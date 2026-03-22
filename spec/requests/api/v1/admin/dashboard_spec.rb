require "rails_helper"

RSpec.describe "Api::V1::Admin::Dashboard", type: :request do
  before { ENV["ADMIN_EMAIL"] = "admin@craftitapp.com" }

  describe "GET /api/v1/admin/dashboard/stats" do
    it "returns dashboard statistics" do
      create(:product, :with_inventory)
      create(:order, :processing)

      admin_get "/api/v1/admin/dashboard/stats"

      expect(response).to have_http_status(:ok)
      expect(json_data).to have_key(:total_products)
      expect(json_data).to have_key(:total_orders)
      expect(json_data).to have_key(:total_revenue)
      expect(json_data).to have_key(:low_stock_count)
    end
  end
end
