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
end
