class Admin::WhitelistedIpsController < Admin::BaseController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    record = WhitelistedIp.find_or_initialize_by(ip: params.fetch(:ip))
    record.visitor    = Trackguard::Visitor.find_by(ip: record.ip)
    record.expires_at = params.fetch(:expires_at, 7.days.from_now)
    record.save!
    Rails.cache.delete("whitelisted_ips")

    render json: { status: "ok", ip: record.ip, expires_at: record.expires_at }
  rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
    render json: { status: "error", message: e.message }, status: :unprocessable_entity
  end

  private

  def authenticate
    return if valid_api_token?

    super
  end
end
