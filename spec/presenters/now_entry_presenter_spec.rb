require "rails_helper"

RSpec.describe NowEntryPresenter do
  it "content renders markdown to HTML" do
    now_entry = NowEntry.new(content: "**Bold** and _italic_.")
    presenter = NowEntryPresenter.new(now_entry)
    expect(presenter.content).to include("<strong>Bold</strong>")
  end

  it "updated_at formats timestamp as Month D, YYYY" do
    now_entry = NowEntry.new(updated_at: Time.zone.local(2026, 3, 5, 12, 0, 0))
    presenter = NowEntryPresenter.new(now_entry)
    expect(presenter.updated_at).to eq("March 5, 2026")
  end

  it "content handles nil gracefully" do
    now_entry = NowEntry.new(content: nil)
    presenter = NowEntryPresenter.new(now_entry)
    expect(presenter.content.strip).to eq("")
  end
end
