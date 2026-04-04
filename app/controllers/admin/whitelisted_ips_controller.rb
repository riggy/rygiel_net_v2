class Admin::WhitelistedIpsController < Admin::BaseController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    record = WhitelistedIp.find_or_initialize_by(ip: params.fetch(:ip))
    record.expires_at = params.fetch(:expires_at, 7.days.from_now)
    record.save!

    render json: { status: "ok", ip: record.ip, expires_at: record.expires_at }
  rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
    render json: { status: "error", message: e.message }, status: :unprocessable_entity
  end

  private

  def authenticate
    return if valid_api_token?

    super
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
