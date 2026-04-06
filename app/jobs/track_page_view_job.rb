class TrackPageViewJob < ApplicationJob
  queue_as :default

  def perform(path:, ip:, user_agent:, referer:, session_id: nil, trace_id: nil, source: nil)
    hashed_session_id = Digest::SHA256.hexdigest(session_id) if session_id.present?

    visitor = Visitor.find_or_create_by!(ip: ip) do |v|
      v.user_agent    = user_agent
      v.first_seen_at = Time.current
      v.last_seen_at  = Time.current
    end
    visitor.update!(last_seen_at: Time.current, user_agent: user_agent)

    PageView.create_with(source:)
            .find_or_create_by!(path:, user_agent:, referer:, session_id: hashed_session_id, trace_id:, visitor:)
  end
end
