require "rails_helper"

RSpec.describe "CORS", type: :request do
  it "allows requests from the configured origin" do
    get "/up", headers: {
      "Origin" => "http://localhost:3000",
      "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "GET"
    }

    expect(response.headers["Access-Control-Allow-Origin"]).to eq("http://localhost:3000")
  end
end
