source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.2"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Load environment variables from .env
gem "dotenv-rails", groups: [:development, :test]

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

# JSON serialization
gem "jsonapi-serializer"

# Pagination
gem "pagy", "~> 43"

# JWT verification
gem "jwt", "~> 2.10"

# HTTP client (for JWKS fetching)
gem "faraday", "~> 2.12"

# Slugs
gem "friendly_id", "~> 5.5"

# State machines (orders, shipments)
gem "aasm", "~> 5.5"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false

  # Testing
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails"
  gem "faker"

  # N+1 detection
  gem "bullet"
end

group :development do
  # Schema annotations in model files (Rails Lens - modern alternative to annotate)
  gem "rails_lens"
end
