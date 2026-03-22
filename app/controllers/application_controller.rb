class ApplicationController < ActionController::API
  include Rails.application.routes.url_helpers

  private

  def render_success(data, status: :ok, meta: nil)
    body = { data: data }
    body[:meta] = meta if meta
    render json: body, status: status
  end

  def render_created(data)
    render_success(data, status: :created)
  end

  def render_error(code:, message:, status:, details: nil)
    body = { error: { code: code, message: message } }
    body[:error][:details] = details if details
    render json: body, status: status
  end

  def render_not_found(message = "Resource not found")
    render_error(code: "not_found", message: message, status: :not_found)
  end

  def render_unauthorized(message = "Unauthorized")
    render_error(code: "unauthorized", message: message, status: :unauthorized)
  end

  def render_forbidden(message = "Forbidden")
    render_error(code: "forbidden", message: message, status: :forbidden)
  end

  def render_validation_error(record)
    render_error(
      code: "validation_error",
      message: "Validation failed",
      status: :unprocessable_entity,
      details: record.errors.messages
    )
  end
end
