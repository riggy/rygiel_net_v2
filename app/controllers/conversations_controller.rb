class ConversationsController < ApplicationController
  before_action :require_ai_chatbot_enabled

  def new
  end

  def create
    @conversation = Conversation.create!(
      ip:               request.remote_ip,
      visitor:          Trackguard::Visitor.find_by(ip: request.remote_ip),
      session_id:       Digest::SHA256.hexdigest(session.id.to_s),
      last_activity_at: Time.current
    )

    redirect_to @conversation
  end

  def show
    @conversation = Conversation.find(params[:id])
    @messages     = @conversation.messages
  end

  private

  def require_ai_chatbot_enabled
    head :not_found unless Flipper.enabled?(:ai_chatbot)
  end
end
