module RequestHelpers
  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  def json_data
    json_response[:data]
  end

  def json_error
    json_response[:error]
  end

  def json_meta
    json_response[:meta]
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
