class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate

  private

  def authenticate
    authenticate_or_request_with_http_basic("Admin") do |name, password|
      ActiveSupport::SecurityUtils.secure_compare(name, Rails.application.credentials.dig(:admin, :username)) &
        ActiveSupport::SecurityUtils.secure_compare(password, Rails.application.credentials.dig(:admin, :password))
    end
  end

  def valid_api_token?
    token = bearer_token
    expected = Rails.application.credentials.dig(:admin, :analytics_token).to_s
    expected.present? && ActiveSupport::SecurityUtils.secure_compare(token.to_s, expected)
  end

  def bearer_token
    request.headers["Authorization"]&.then { |h| h[/\ABearer (.+)\z/, 1] }
  end
end
