class GenerateChatResponseJob < ApplicationJob
  queue_as :default

  FALLBACK = "I'm sorry, I'm having trouble responding right now. Please try again."

  def perform(conversation_id)
    conversation = Conversation.find_by(id: conversation_id)
    return unless conversation

    system_prompt = SiteConfig.get("chatbot_system_prompt").presence || default_system_prompt
    api_messages  = conversation.messages.for_api.map { |m| { role: m.role, content: m.content } }

    content = ChatbotService.call(system_prompt:, messages: api_messages)
    message = conversation.messages.create!(role: "assistant", content: content)
    conversation.update_columns(last_activity_at: Time.current)

    broadcast_response(conversation, message)
  rescue => e
    Rails.logger.error("GenerateChatResponseJob failed for conversation #{conversation_id}: #{e.message}")
    fallback = conversation&.messages&.create(role: "assistant", content: FALLBACK)
    broadcast_response(conversation, fallback) if fallback&.persisted?
  end

  private

  def broadcast_response(conversation, message)
    Turbo::StreamsChannel.broadcast_remove_to(
      conversation,
      target: ActionView::RecordIdentifier.dom_id(conversation, :thinking)
    )
    Turbo::StreamsChannel.broadcast_append_to(
      conversation,
      target:  ActionView::RecordIdentifier.dom_id(conversation, :messages),
      partial: "conversations/message",
      locals:  { message: }
    )
  end

  def default_system_prompt
    <<~PROMPT
      You are an AI assistant representing Krzysztof Rygielski, a software developer.
      You speak on his behalf to visitors of his personal website rygiel.net.
      Be helpful, professional, and concise. Discuss his work, experience, and projects.
      For questions you cannot answer, suggest contacting him directly.
    PROMPT
  end
end
