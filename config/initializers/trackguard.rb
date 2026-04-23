Trackguard.authenticate_admin_with = proc do
  authenticate_or_request_with_http_basic("Admin") do |name, password|
    ActiveSupport::SecurityUtils.secure_compare(name, Rails.application.credentials.dig(:admin, :username)) &
      ActiveSupport::SecurityUtils.secure_compare(password, Rails.application.credentials.dig(:admin, :password))
  end
end

Trackguard.api_token = Rails.application.credentials.dig(:trackguard, :api_token)
