require "test_helper"

class PostPresenterTest < ActiveSupport::TestCase
  test "body renders markdown to HTML" do
    post = Post.new(title: "Test", body: "## Heading\n\nParagraph.")
    presenter = PostPresenter.new(post)
    result = presenter.body
    assert_includes result, "<h2>Heading</h2>"
    assert_includes result, "<p>Paragraph.</p>"
  end

  test "body handles nil gracefully" do
    post = Post.new(title: "Test", body: nil)
    presenter = PostPresenter.new(post)
    assert_equal "", presenter.body.strip
  end
end
