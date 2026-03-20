class NowEntryPresenter
  include MarkdownParser

  def initialize(now_entry)
    @now_entry = now_entry
  end

  def content
    markdown(@now_entry.content)
  end
end
