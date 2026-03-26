module PageTracker
  extend ActiveSupport::Concern

  private

  def track_page_view
    return unless request.get?
    return unless request.format.html?

    PageViewRecorder.call(
      path:       request.path,
      ip:         request.remote_ip,
      user_agent: request.user_agent.to_s,
      referer:    request.referer,
      session_id: session.id.to_s,
      trace_id:   @trace_id
    )
  end
end
