require "test_helper"

class NowEntryPresenterTest < ActiveSupport::TestCase
  test "content renders markdown to HTML" do
    now_entry = NowEntry.new(content: "**Bold** and _italic_.")
    presenter = NowEntryPresenter.new(now_entry)
    assert_includes presenter.content, "<strong>Bold</strong>"
  end

  test "updated_at formats timestamp as Month D, YYYY" do
    now_entry = NowEntry.new(updated_at: Time.zone.local(2026, 3, 5, 12, 0, 0))
    presenter = NowEntryPresenter.new(now_entry)
    assert_equal "March 5, 2026", presenter.updated_at
  end

  test "content handles nil gracefully" do
    now_entry = NowEntry.new(content: nil)
    presenter = NowEntryPresenter.new(now_entry)
    assert_equal "", presenter.content.strip
  end
end
