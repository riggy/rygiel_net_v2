class Admin::Trackguard::DashboardsController < Admin::BaseController
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

    @recent = Trackguard::PageView.order(created_at: :desc).limit(20).includes(:visitor)
  end
end
