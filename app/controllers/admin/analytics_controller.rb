class Admin::AnalyticsController < Admin::BaseController
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

    @recent = PageView.order(created_at: :desc).limit(20)

    respond_to do |format|
      format.html
      format.json
    end
  end
end
