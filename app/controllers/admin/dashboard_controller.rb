class Admin::DashboardController < Admin::BaseController
  def index
    @published_posts_count = Post.published.count
    @draft_posts_count     = Post.where(published: false).count
    @latest_post           = Post.published.first

    @latest_now_entry = NowEntry.order(updated_at: :desc).first

    @cv = CurriculumVitae.current

    @site_configs = SiteConfig.order(:key)
  end
end
