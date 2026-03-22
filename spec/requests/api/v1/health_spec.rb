require "rails_helper"

RSpec.describe "API V1 Health", type: :request do
  describe "GET /api/v1/health" do
    it "returns ok status with consistent response format" do
      get "/api/v1/health"

      expect(response).to have_http_status(:ok)
      expect(json_data).to eq({ status: "ok" })
    end
  end
end
