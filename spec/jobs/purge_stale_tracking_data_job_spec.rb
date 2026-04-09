require "rails_helper"

RSpec.describe PurgeStaleTrackingDataJob, type: :job do
  CUTOFF = PurgeStaleTrackingDataJob::RETENTION_DAYS.days.ago

  before do
    Trackguard::PageView.delete_all
    Trackguard::Visitor.delete_all
  end

  def run_job
    described_class.perform_now
  end

  # --- page_views ---

  it "deletes page_views older than RETENTION_DAYS" do
    v = create(:visitor)
    create(:page_view, visitor: v, created_at: CUTOFF - 1.day)
    run_job
    expect(Trackguard::PageView.count).to eq(0)
  end

  it "keeps page_views within RETENTION_DAYS" do
    v = create(:visitor)
    create(:page_view, visitor: v, created_at: CUTOFF + 1.day)
    run_job
    expect(Trackguard::PageView.count).to eq(1)
  end

  # --- visitors ---

  it "deletes unflagged visitor with no remaining page_views and stale last_seen_at" do
    v = create(:visitor, last_seen_at: CUTOFF - 1.day)
    run_job
    expect(Trackguard::Visitor.exists?(v.id)).to be false
  end

  it "keeps visitor whose last_seen_at is within retention window" do
    v = create(:visitor, last_seen_at: CUTOFF + 1.day)
    run_job
    expect(Trackguard::Visitor.exists?(v.id)).to be true
  end

  it "keeps stale visitor who still has recent page_views" do
    v = create(:visitor, last_seen_at: CUTOFF - 1.day)
    create(:page_view, visitor: v, created_at: CUTOFF + 1.day)
    run_job
    expect(Trackguard::Visitor.exists?(v.id)).to be true
  end

  it "keeps flagged visitor regardless of last_seen_at" do
    v = create(:visitor, :flagged, last_seen_at: CUTOFF - 1.day)
    run_job
    expect(Trackguard::Visitor.exists?(v.id)).to be true
  end

  # --- associations ---

  it "nullifies visitor_id on whitelisted_ip before deleting visitor" do
    v = create(:visitor, last_seen_at: CUTOFF - 1.day)
    wl = create(:whitelisted_ip, visitor: v, ip: v.ip)
    run_job
    expect(wl.reload.visitor_id).to be_nil
  end

  it "nullifies visitor_id on conversation before deleting visitor" do
    v = create(:visitor, last_seen_at: CUTOFF - 1.day)
    convo = create(:conversation, visitor: v, ip: v.ip)
    run_job
    expect(convo.reload.visitor_id).to be_nil
  end

  # --- no-op ---

  it "completes without error when nothing to purge" do
    expect { run_job }.not_to raise_error
  end
end
