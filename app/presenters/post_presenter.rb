class PostPresenter < SimpleDelegator
  include MarkdownParser

  def initialize(post)
    @post = post
    super
  end

  def body
    markdown(@post.body)
  end

  def chatbot_context
    "- **#{title}** (#{published_at&.strftime('%b %Y')}): #{@post.body.truncate(200)}"
  end
end
