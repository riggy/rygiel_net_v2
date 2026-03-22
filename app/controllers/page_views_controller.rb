class PageViewsController < ApplicationController
  BOT_REGEX = /Googlebot|Bingbot|Slurp|DuckDuckBot|Baidu|YandexBot|facebookexternalhit|Twitterbot|LinkedInBot|curl|wget|python-requests|python-urllib|Go-http-client|libwww|Java|Ruby|bot|crawl|spider/i

  def create
    user_agent = request.user_agent.to_s
    path = params[:path].to_s

    return head :no_content if BOT_REGEX.match?(user_agent)
    return head :no_content if path.blank? || path.start_with?("/admin")

    TrackPageViewJob.perform_later(
      path: path,
      ip: request.remote_ip,
      user_agent: user_agent,
      referer: request.referer,
      session_id: session.id.to_s
    )

    head :no_content
  end
end
