module PageTracker
  extend ActiveSupport::Concern

  BOT_REGEX = /Googlebot|Bingbot|Slurp|DuckDuckBot|Baidu|YandexBot|facebookexternalhit|Twitterbot|LinkedInBot|curl|wget|python-requests|python-urllib|Go-http-client|libwww|Java|Ruby|bot|crawl|spider/i

  included do
    after_action :track_page_view
  end

  private

  def track_page_view
    user_agent = request.user_agent.to_s
    return unless request.get?
    return unless request.format.html?
    return if request.path.start_with?("/admin")
    return if user_agent.match?(BOT_REGEX)

    TrackPageViewJob.perform_later(
      path: request.path,
      ip: request.remote_ip,
      user_agent: user_agent,
      referer: request.referer,
      session_id: session.id.to_s
    )
  end
end
