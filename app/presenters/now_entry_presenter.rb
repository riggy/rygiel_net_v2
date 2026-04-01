class NowEntryPresenter
  include MarkdownParser

  def initialize(now_entry)
    @now_entry = now_entry
  end

  def updated_at
    @now_entry.updated_at.strftime("%B %-d, %Y")
  end

  def content
    markdown(@now_entry.content)
  end

  def chatbot_context
    @now_entry.content
  end
end
