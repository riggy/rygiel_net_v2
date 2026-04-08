class Admin::BlockedUserAgentsController < Admin::BaseController
  skip_before_action :verify_authenticity_token

  def index
    render json: BlockedUserAgent.order(:pattern).pluck(:pattern)
  end

  def create
    record = BlockedUserAgent.find_or_create_by!(pattern: params.fetch(:user_agent))
    Rails.cache.delete("blocked_user_agent_patterns")
    render json: { status: "ok", pattern: record.pattern }
  rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid => e
    render json: { status: "error", message: e.message }, status: :unprocessable_entity
  end

  private

  def authenticate
    return if valid_api_token?

    super
  end
end
