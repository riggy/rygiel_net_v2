class TrackPageViewJob < ApplicationJob
  queue_as :default

  def perform(path:, ip:, user_agent:, referer:, session_id: nil, trace_id: nil)
    hashed_session_id = Digest::SHA256.hexdigest(session_id) if session_id.present?
    PageView.find_or_create_by!(path:, ip:, user_agent:, referer:, session_id: hashed_session_id, trace_id:)
  end
end
