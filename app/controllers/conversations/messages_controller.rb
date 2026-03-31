module Conversations
  class MessagesController < ApplicationController
    before_action :require_ai_chatbot_enabled
    before_action :set_conversation

    def create
      @message = @conversation.messages.build(
        role:    "user",
        content: message_params[:content].to_s.strip
      )

      if @message.save
        @conversation.update_columns(last_activity_at: Time.current)
        GenerateChatResponseJob.perform_later(@conversation.id)
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @conversation }
      end
    end

    private

    def set_conversation
      @conversation = Conversation.find(params[:conversation_id])
    end

    def require_ai_chatbot_enabled
      head :not_found unless Flipper.enabled?(:ai_chatbot)
    end

    def message_params
      params.require(:message).permit(:content)
    end
  end
end
