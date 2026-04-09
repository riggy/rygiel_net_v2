class Admin::AnalyticsController < Admin::BaseController
  skip_before_action :verify_authenticity_token, only: [ :flag_visitor, :unflag_visitor ]
  def show
    @total_today  = Trackguard::PageView.today.count
    @total_week   = Trackguard::PageView.this_week.count
    @total_month  = Trackguard::PageView.this_month.count

    @top_pages = Trackguard::PageView.last_30
                         .group(:path)
                         .order("count_all DESC")
                         .limit(10)
                         .count

    @top_referrers = Trackguard::PageView.last_30
                             .with_referrer
                             .group(:referer)
                             .order("count_all DESC")
                             .limit(10)
                             .count

    @top_sources = Trackguard::PageView.last_30
                           .with_source
                           .group(:source)
                           .order("count_all DESC")
                           .limit(10)
                           .count

    @top_referral_links = ReferralLink.where("clicks > 0").order(clicks: :desc).limit(10)

    @recent = Trackguard::PageView.order(created_at: :desc).limit(20).includes(visitor: :whitelisted_ip)

    respond_to do |format|
      format.html
      format.json
    end
  end

  def flag_visitor
    visitor = Trackguard::Visitor.find_by!(ip: params[:ip])
    visitor.update!(flagged_at: Time.current, flag_reason: params[:flag_reason], flagged_by: params[:flagged_by])
    Rails.cache.delete("flagged_ips")
    render json: { status: "ok", ip: visitor.ip, flagged_at: visitor.flagged_at }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Visitor not found" }, status: :not_found
  end

  def unflag_visitor
    visitor = Trackguard::Visitor.find_by!(ip: params[:ip])
    visitor.update!(flagged_at: nil, flag_reason: nil, flagged_by: nil)
    Rails.cache.delete("flagged_ips")
    render json: { status: "ok", ip: visitor.ip }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Visitor not found" }, status: :not_found
  end

  private

  def authenticate
    return if valid_api_token?
    super
  end
end
