class ChatbotContext < ApplicationService
  def call
    sections = [
      site_config_section,
      projects_section,
      blog_section,
      now_section
    ].compact

    sections.join("\n\n")
  end

  private

  def site_config_section
    config = SiteConfigPresenter.new(SiteConfig.all.pluck(:key, :value).to_h)
    text = config.chatbot_context
    text.present? ? "## About & Contact\n#{text}" : nil
  end

  def projects_section
    projects = Project.featured.order(created_at: :desc)
    return if projects.empty?
    lines = projects.map { |p| ProjectPresenter.new(p).chatbot_context }
    "## Projects\n#{lines.join("\n")}"
  end

  def blog_section
    posts = Post.published.limit(5)
    return if posts.empty?
    lines = posts.map { |p| PostPresenter.new(p).chatbot_context }
    "## Recent Blog Posts\n#{lines.join("\n")}"
  end

  def now_section
    entry = NowEntry.order(created_at: :desc).first
    return unless entry
    "## What Krzysztof Is Doing Now\n#{NowEntryPresenter.new(entry).chatbot_context}"
  end
end
