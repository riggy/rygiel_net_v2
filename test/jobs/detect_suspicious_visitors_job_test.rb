require "test_helper"

class DetectSuspiciousVisitorsJobTest < ActiveJob::TestCase
  def setup
    PageView.delete_all
    Visitor.delete_all
  end

  # --- helpers ---

  def make_visitor(flagged_at: nil, flag_reason: nil)
    Visitor.create!(
      ip:           "#{rand(1..254)}.#{rand(1..254)}.#{rand(1..254)}.#{rand(1..254)}",
      user_agent:   "TestAgent",
      first_seen_at: Time.current,
      last_seen_at:  Time.current,
      flagged_at:,
      flag_reason:
    )
  end

  def make_views(visitor, count:, path: "/blog", session_id: "abc123", referer: "https://example.com", age: 1.hour.ago)
    count.times do
      PageView.create!(
        visitor:,
        path:,
        session_id:,
        referer:,
        created_at: age
      )
    end
  end

  def run_job
    DetectSuspiciousVisitorsJob.perform_now
  end

  # --- hard flag ---

  test "flags visitor with 50+ page views in 24h (hard flag)" do
    v = make_visitor
    make_views(v, count: 50)
    run_job
    v.reload
    assert_not_nil v.flagged_at
    assert_includes v.flag_reason, "hard flag threshold"
  end

  test "flags visitor with exactly 50 views (hard flag boundary)" do
    v = make_visitor
    make_views(v, count: 50)
    run_job
    assert_not_nil v.reload.flagged_at
  end

  # --- scoring: flagged cases ---

  test "flags visitor with 12 views + no session + no referer (score 9)" do
    v = make_visitor
    make_views(v, count: 12, session_id: nil, referer: nil)
    run_job
    assert_not_nil v.reload.flagged_at
  end

  test "flags visitor with no session + no referer, 3 views (score 5)" do
    v = make_visitor
    make_views(v, count: 3, session_id: nil, referer: nil)
    run_job
    assert_not_nil v.reload.flagged_at
  end

  test "flags visitor with 4 views all to root + no session (score 6)" do
    v = make_visitor
    make_views(v, count: 4, path: "/", session_id: nil)
    run_job
    assert_not_nil v.reload.flagged_at
  end

  test "flags visitor with single non-root path + no session (score 5)" do
    v = make_visitor
    make_views(v, count: 3, path: "/about", session_id: nil)
    run_job
    assert_not_nil v.reload.flagged_at
  end

  # --- scoring: NOT flagged cases ---

  test "does not flag visitor with 8 views all having session (score 2)" do
    v = make_visitor
    make_views(v, count: 8, session_id: "hashed_session_value")
    run_job
    assert_nil v.reload.flagged_at
  end

  test "does not flag visitor with no session alone, 3 views (score 3)" do
    v = make_visitor
    # Use distinct paths so single_path (+2) does not also trigger
    %w[/ /blog /about].each do |path|
      PageView.create!(visitor: v, path:, session_id: nil, referer: "https://google.com", created_at: 1.hour.ago)
    end
    run_job
    assert_nil v.reload.flagged_at
  end

  test "does not flag visitor with no referer alone (score 2)" do
    v = make_visitor
    make_views(v, count: 3, session_id: "abc123", referer: nil)
    run_job
    assert_nil v.reload.flagged_at
  end

  # --- boundary: 80% threshold is not > 80% ---

  test "does not trigger no-session signal at exactly 80% blank" do
    v = make_visitor
    # 8 blank + 2 with session = exactly 80%, which is NOT > 0.8 (the threshold)
    # Use distinct paths and present referers so no other signals trigger.
    # Score: high_volume (10 views = +4) only → 4, below threshold 5.
    8.times  { |i| PageView.create!(visitor: v, path: "/page-#{i}",  session_id: nil,      referer: "https://google.com", created_at: 1.hour.ago) }
    2.times  { |i| PageView.create!(visitor: v, path: "/other-#{i}", session_id: "hashed", referer: "https://google.com", created_at: 1.hour.ago) }
    run_job
    assert_nil v.reload.flagged_at
  end

  # --- already-flagged visitors are skipped ---

  test "does not modify already-flagged visitor" do
    original_time   = 1.day.ago
    original_reason = "original reason"
    v = make_visitor(flagged_at: original_time, flag_reason: original_reason)
    make_views(v, count: 25, session_id: nil, referer: nil)
    run_job
    v.reload
    assert_in_delta original_time, v.flagged_at, 1.second
    assert_equal original_reason, v.flag_reason
  end

  # --- views outside 24h window are ignored ---

  test "does not flag visitor whose views are all older than 24h" do
    v = make_visitor
    make_views(v, count: 25, session_id: nil, referer: nil, age: 25.hours.ago)
    run_job
    assert_nil v.reload.flagged_at
  end

  # --- flag_reason content ---

  test "flag_reason describes triggered signals" do
    v = make_visitor
    make_views(v, count: 3, path: "/", session_id: nil, referer: nil)
    run_job
    v.reload
    assert_not_nil v.flagged_at
    assert_includes v.flag_reason, "no session"
    assert_includes v.flag_reason, "no referer"
  end

  # --- no-op when nothing to process ---

  test "completes without error when no unflagged visitors exist" do
    assert_nothing_raised { run_job }
  end

  test "completes without error when no page views in last 24h" do
    make_visitor
    assert_nothing_raised { run_job }
  end
end
