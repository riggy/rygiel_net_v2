Trackguard.authenticate_admin_with = proc do
  authenticate_or_request_with_http_basic("Admin") do |name, password|
    ActiveSupport::SecurityUtils.secure_compare(name, Rails.application.credentials.dig(:admin, :username)) &
      ActiveSupport::SecurityUtils.secure_compare(password, Rails.application.credentials.dig(:admin, :password))
  end
end
