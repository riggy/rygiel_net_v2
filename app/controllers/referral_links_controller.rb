class ReferralLinksController < ApplicationController
  def show
    link = ReferralLink.active.find_by(slug: params[:slug])

    if link.nil?
      redirect_to root_path, status: :moved_permanently
      return
    end

    unless Trackguard::PageViewRecorder::BOT_REGEX.match?(request.user_agent.to_s)
      ReferralLink.increment_counter(:clicks, link.id)
    end

    redirect_to link.destination_url, status: :found, allow_other_host: false
  end
end
