class TrackPageViewJob < ApplicationJob
  queue_as :default

  def perform(path:, ip:, user_agent:, referer:, session_id: nil)
    hashed_session_id = Digest::SHA256.hexdigest(session_id) if session_id.present?
    PageView.create!(path:, ip:, user_agent:, referer:, session_id: hashed_session_id)
  end
end
