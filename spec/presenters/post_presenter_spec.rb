require "rails_helper"

RSpec.describe PostPresenter do
  it "body renders markdown to HTML" do
    post = Post.new(title: "Test", body: "## Heading\n\nParagraph.")
    presenter = PostPresenter.new(post)
    result = presenter.body
    expect(result).to include("<h2>Heading</h2>")
    expect(result).to include("<p>Paragraph.</p>")
  end

  it "body handles nil gracefully" do
    post = Post.new(title: "Test", body: nil)
    presenter = PostPresenter.new(post)
    expect(presenter.body.strip).to eq("")
  end

  describe "#chatbot_context" do
    it "returns title, date, and truncated body" do
      post = Post.new(title: "Rails Tips", body: "Some great tips about Rails.", published_at: Time.new(2026, 3, 15))
      presenter = PostPresenter.new(post)
      expect(presenter.chatbot_context).to include("**Rails Tips**")
      expect(presenter.chatbot_context).to include("Mar 2026")
      expect(presenter.chatbot_context).to include("Some great tips")
    end
  end
end
