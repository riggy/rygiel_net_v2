class PagesController < ApplicationController
  track_page_views
  def home
    @projects = Project.featured.positioned
    @posts = Post.published.limit(3)
    @now_entry = NowEntryPresenter.new(NowEntry.order(created_at: :desc).first)
    @site_config = SiteConfigPresenter.new(SiteConfig.all.pluck(:key, :value).to_h)
  end
end
