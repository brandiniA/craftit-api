class JwtAuthentication
  BEARER_PATTERN = /\ABearer\s+(.+)\z/i

  def initialize(app)
    @app = app
  end

  def call(env)
    if Rails.env.test? && env["HTTP_AUTH_USER_ID"].present?
      env["auth_user_id"] = env["HTTP_AUTH_USER_ID"]
      env["auth_user_email"] = env["HTTP_AUTH_USER_EMAIL"] if env["HTTP_AUTH_USER_EMAIL"].present?
      return @app.call(env)
    end

    token = extract_token(env)

    if token
      payload = decode_token(token)
      if payload
        env["auth_user_id"] = payload["sub"]
        env["auth_user_email"] = payload["email"]
      end
    end

    @app.call(env)
  end

  private

  def extract_token(env)
    auth_header = env["HTTP_AUTHORIZATION"]
    return nil unless auth_header

    match = auth_header.match(BEARER_PATTERN)
    match&.[](1)
  end

  def decode_token(token)
    jwks = fetch_jwks
    return nil unless jwks

    decoded = JWT.decode(
      token,
      nil,
      true,
      {
        algorithms: [ jwt_config.algorithm ],
        jwks: jwks,
        iss: jwt_config.issuer,
        verify_iss: jwt_config.issuer.present?
      }
    )
    decoded.first
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError => e
    Rails.logger.warn("JWT decode failed: #{e.message}")
    nil
  end

  def fetch_jwks
    @jwks = nil if jwks_cache_expired?

    @jwks ||= begin
      response = Faraday.get(jwt_config.jwks_url)
      if response.success?
        @jwks_fetched_at = Time.current
        JSON.parse(response.body)
      end
    rescue Faraday::Error => e
      Rails.logger.error("JWKS fetch failed: #{e.message}")
      nil
    end
  end

  def jwks_cache_expired?
    return true unless @jwks_fetched_at
    Time.current - @jwks_fetched_at > jwt_config.jwks_cache_ttl
  end

  def jwt_config
    Rails.application.config.jwt
  end
end
