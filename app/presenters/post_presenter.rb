class PostPresenter < SimpleDelegator

  include MarkdownParser

  def initialize(post)
    @post = post
    super
  end

  def body
    markdown(@post.body)
  end
end