require "rails_helper"

RSpec.describe JwtAuthentication do
  let(:app) { ->(env) { [ 200, {}, [ "OK" ] ] } }
  let(:middleware) { described_class.new(app) }

  describe "#call" do
    context "when no Authorization header is present" do
      it "passes through without setting auth_user_id" do
        env = Rack::MockRequest.env_for("/api/v1/cart")
        status, response_env, = middleware.call(env)

        expect(status).to eq(200)
        expect(response_env["auth_user_id"]).to be_nil
      end
    end

    context "when Authorization header has invalid format" do
      it "passes through without setting auth_user_id" do
        env = Rack::MockRequest.env_for(
          "/api/v1/cart",
          "HTTP_AUTHORIZATION" => "InvalidToken"
        )
        status, response_env, = middleware.call(env)

        expect(status).to eq(200)
        expect(response_env["auth_user_id"]).to be_nil
      end
    end
  end
end
