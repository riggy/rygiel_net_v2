require "test_helper"

class PageViewRecorderTest < ActiveJob::TestCase
  DEFAULT_PARAMS = {
    path:       "/blog",
    ip:         "1.2.3.4",
    user_agent: "Mozilla/5.0",
    referer:    "https://example.com",
    session_id: "abc123",
    trace_id:   "trace-xyz"
  }.freeze

  def call(**overrides)
    PageViewRecorder.call(**DEFAULT_PARAMS.merge(overrides))
  end

  test "enqueues TrackPageViewJob with correct args for valid page view" do
    assert_enqueued_with(job: TrackPageViewJob, args: [ {
      path:       "/blog",
      ip:         "1.2.3.4",
      user_agent: "Mozilla/5.0",
      referer:    "https://example.com",
      session_id: "abc123",
      trace_id:   "trace-xyz"
    } ]) do
      call
    end
  end

  test "does not enqueue job for Googlebot" do
    assert_no_enqueued_jobs do
      call(user_agent: "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")
    end
  end

  test "does not enqueue job for curl" do
    assert_no_enqueued_jobs do
      call(user_agent: "curl/7.88.1")
    end
  end

  test "does not enqueue job for admin path" do
    assert_no_enqueued_jobs do
      call(path: "/admin/posts")
    end
  end

  test "does not enqueue job for blank path" do
    assert_no_enqueued_jobs do
      call(path: "")
    end
  end

  test "does not enqueue job for nil path" do
    assert_no_enqueued_jobs do
      call(path: nil)
    end
  end
end
