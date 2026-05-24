Trackguard.authenticate_admin_with = proc do
  authenticate_or_request_with_http_basic("Admin") do |name, password|
    ActiveSupport::SecurityUtils.secure_compare(name, Rails.application.credentials.dig(:admin, :username)) &
      ActiveSupport::SecurityUtils.secure_compare(password, Rails.application.credentials.dig(:admin, :password))
  end
end

# For now let's use local adapter
# Trackguard.hub_api_key = Rails.application.credentials.dig(:trackguard, :hub_api_key)
# Trackguard.hub_secret_key = Rails.application.credentials.dig(:trackguard, :hub_secret_key)
# Trackguard.adapter = :hub
# Trackguard.hub_url = "https://app.trackguard.dev"

Trackguard.local_api_token = Rails.application.credentials.dig(:trackguard, :local_api_token)
