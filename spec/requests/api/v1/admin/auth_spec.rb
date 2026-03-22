require "rails_helper"

RSpec.describe "Admin Authorization", type: :request do
  before do
    ENV["ADMIN_EMAIL"] = "admin@craftitapp.com"
  end

  it "allows admin email" do
    admin_get "/api/v1/admin/dashboard/stats"
    expect(response).not_to have_http_status(:forbidden)
  end

  it "rejects non-admin email" do
    profile = create(:customer_profile)
    authenticated_get "/api/v1/admin/dashboard/stats", customer_profile: profile
    expect(response).to have_http_status(:forbidden)
  end

  it "rejects unauthenticated requests" do
    get "/api/v1/admin/dashboard/stats"
    expect(response).to have_http_status(:unauthorized)
  end
end
