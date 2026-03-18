class BlogController < ApplicationController
  PER_PAGE = 10

  def index
    @page = (params[:page] || 1).to_i
    @total = Post.published.count
    @total_pages = (@total / PER_PAGE.to_f).ceil
    @posts = Post.published.limit(PER_PAGE).offset((@page - 1) * PER_PAGE).map {|post| PostPresenter.new(post)}
  end

  def show
    @post = PostPresenter.new(Post.published.find(params[:id]))
  end
end