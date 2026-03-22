require "rails_helper"

RSpec.describe "API V1 Error Handling", type: :request do
  describe "404 for unknown routes within API namespace" do
    it "returns not found for non-existent API routes" do
      get "/api/v1/nonexistent"

      expect(response).to have_http_status(:not_found)
    end
  end
end
