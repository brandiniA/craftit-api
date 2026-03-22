module AuthHelpers
  def auth_headers(customer_profile)
    { "HTTP_AUTH_USER_ID" => customer_profile.auth_user_id }
  end

  def authenticated_get(path, customer_profile:, **options)
    get path, headers: auth_headers(customer_profile), **options
  end

  def authenticated_post(path, customer_profile:, **options)
    post path, headers: auth_headers(customer_profile), **options
  end

  def authenticated_patch(path, customer_profile:, **options)
    patch path, headers: auth_headers(customer_profile), **options
  end

  def authenticated_delete(path, customer_profile:, **options)
    delete path, headers: auth_headers(customer_profile), **options
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
