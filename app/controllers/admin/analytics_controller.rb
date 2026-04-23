class Admin::AnalyticsController < Admin::BaseController
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

  private

  def authenticate
    return if valid_api_token?
    super
  end
end
