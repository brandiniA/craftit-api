Rails.application.config.jwt = ActiveSupport::OrderedOptions.new
Rails.application.config.jwt.jwks_url = ENV.fetch("JWKS_URL", "http://localhost:3000/api/auth/jwks")
Rails.application.config.jwt.algorithm = ENV.fetch("JWT_ALGORITHM", "RS256")
Rails.application.config.jwt.issuer = ENV.fetch("JWT_ISSUER", nil)
Rails.application.config.jwt.jwks_cache_ttl = ENV.fetch("JWKS_CACHE_TTL", 3600).to_i
