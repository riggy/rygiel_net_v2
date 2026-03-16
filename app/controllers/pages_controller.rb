class PagesController < ApplicationController
  def home
    @projects = Project.featured.order(created_at: :desc)
    @posts = Post.published.limit(3)
    @now_entry = NowEntry.order(created_at: :desc).first
  end
end