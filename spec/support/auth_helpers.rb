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

  def admin_headers
    {
      "HTTP_AUTH_USER_ID" => "admin-user",
      "HTTP_AUTH_USER_EMAIL" => ENV.fetch("ADMIN_EMAIL", "admin@craftitapp.com")
    }
  end

  def admin_get(path, **options)
    get path, headers: admin_headers, **options
  end

  def admin_post(path, **options)
    post path, headers: admin_headers, **options
  end

  def admin_patch(path, **options)
    patch path, headers: admin_headers, **options
  end

  def admin_delete(path, **options)
    delete path, headers: admin_headers, **options
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
