class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate

  private

  def authenticate
    authenticate_or_request_with_http_basic("Admin") do |name, password|
      ActiveSupport::SecurityUtils.secure_compare(name, ENV.fetch("ADMIN_USERNAME")) &
        ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch("ADMIN_PASSWORD"))
    end
  end
end