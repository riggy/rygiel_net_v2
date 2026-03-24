class Admin::AnalyticsController < Admin::BaseController
  skip_before_action :verify_authenticity_token, only: [ :flag_visitor ]
  def show
    @total_today  = PageView.today.count
    @total_week   = PageView.this_week.count
    @total_month  = PageView.this_month.count

    @top_pages = PageView.last_30
                         .group(:path)
                         .order("count_all DESC")
                         .limit(10)
                         .count

    @top_referrers = PageView.last_30
                             .where.not(referer: [ nil, "" ])
                             .group(:referer)
                             .order("count_all DESC")
                             .limit(10)
                             .count

    @recent = PageView.order(created_at: :desc).limit(20).includes(:visitor)

    respond_to do |format|
      format.html
      format.json
    end
  end

  def flag_visitor
    visitor = Visitor.find_by!(ip: params[:ip])
    visitor.update!(flagged_at: Time.current, flag_reason: params[:flag_reason], flagged_by: params[:flagged_by])
    render json: { status: "ok", ip: visitor.ip, flagged_at: visitor.flagged_at }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Visitor not found" }, status: :not_found
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
